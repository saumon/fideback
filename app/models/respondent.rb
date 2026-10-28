class Respondent < ApplicationRecord
  belongs_to :campaign
  has_many :answers, dependent: :destroy

  has_secure_token :token, length: 36

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :campaign_id, case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def submitted?
    submitted_at.present?
  end

  # Le lien personnel est encore utilisable et le sondé n'a pas fini de répondre.
  def invitable?
    campaign.accepting_answers? && !submitted?
  end

  # Date l'invitation à la mise en file de l'email, pas à sa livraison.
  def invite!
    transaction do
      update!(last_invited_at: Time.current)
      RespondentMailer.invitation(self).deliver_later
    end
  end

  # Managés sur lesquels ce sondé doit répondre (jamais lui-même).
  def subjects_to_rate
    campaign.subjects.where.not("LOWER(subjects.email) = ?", email.downcase)
  end

  def status
    return :submitted if submitted?
    answers.exists? ? :in_progress : :pending
  end

  # Enregistre les réponses saisies : { subject_id => { question_id => { "rating" => , "body" => } } }.
  # Les entrées vides suppriment la réponse existante. Retourne true si tout est valide.
  def save_answers(input)
    return false unless campaign.accepting_answers? && !submitted?

    valid = true
    transaction do
      subjects = subjects_to_rate.index_by { |subject| subject.id.to_s }
      questions = campaign.questions.index_by { |question| question.id.to_s }

      input.each do |subject_id, per_question|
        next unless (subject = subjects[subject_id.to_s])

        per_question.each do |question_id, values|
          next unless (question = questions[question_id.to_s])

          answer = answers.find_or_initialize_by(subject: subject, question: question)
          answer.rating = question.rating? ? values["rating"].presence : nil
          answer.body = question.comment? ? values["body"] : nil

          if answer.rating.nil? && answer.body.blank?
            answer.destroy if answer.persisted?
          elsif !answer.save
            valid = false
          end
        end
      end
      raise ActiveRecord::Rollback unless valid
    end
    valid
  end

  # Notes manquantes : [ [subject, question], ... ]
  def missing_ratings
    answered = answers.where.not(rating: nil).pluck(:subject_id, :question_id).to_set
    rated_questions = campaign.questions.select(&:rating?)
    subjects_to_rate.flat_map do |subject|
      rated_questions.reject { |question| answered.include?([ subject.id, question.id ]) }.map { |question| [ subject, question ] }
    end
  end

  def submit!
    return false unless campaign.accepting_answers? && !submitted?
    return false if missing_ratings.any?

    update!(submitted_at: Time.current)
  end
end
