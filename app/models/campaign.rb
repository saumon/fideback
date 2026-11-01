class Campaign < ApplicationRecord
  DEFAULT_QUESTIONS = [
    { prompt: "Qualité du travail réalisé cette année", rating: true, comment: true },
    { prompt: "Collaboration et esprit d'équipe", rating: true, comment: true },
    { prompt: "Points forts à valoriser", rating: false, comment: true },
    { prompt: "Axes de progrès", rating: false, comment: true }
  ].freeze

  # Liste de la campagne => rôle que le contact doit avoir dans l'annuaire.
  CONTACT_LISTS = { subjects: :managed, respondents: :surveyable }.freeze

  belongs_to :manager
  has_many :subjects, dependent: :destroy, autosave: true
  has_many :respondents, dependent: :destroy, autosave: true
  has_many :questions, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :campaign

  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: ->(attrs) { attrs["prompt"].blank? }

  enum :status, { draft: 0, running: 1, closed: 2 }, default: :draft

  validates :name, :deadline_on, presence: true
  validate :deadline_in_future, on: :create
  validate :content_frozen_once_launched, on: :update

  before_validation :renumber_questions, if: :draft?
  before_validation :assign_contacts
  validate :new_contacts_valid
  before_save :save_touched_contacts

  def build_default_questions
    DEFAULT_QUESTIONS.each_with_index do |attrs, index|
      questions.build(attrs.merge(position: index))
    end
  end

  # Sélection des managés et sondés parmi les contacts de l'annuaire (identifiants),
  # et nouveaux contacts saisis depuis la campagne ([{ name:, email: }, ...]).
  # Appliqués à la validation, quand le manager de la campagne est connu.
  CONTACT_LISTS.each_key do |list|
    singular = list.to_s.singularize

    define_method(:"#{singular}_contact_ids") { selected_contact_ids(list) }
    define_method(:"#{singular}_contact_ids=") { |ids| contact_selection[list] = ids }
    define_method(:"new_#{singular}_contacts") { new_contacts[list].select(&:new_record?) }
    define_method(:"new_#{singular}_contacts=") { |rows| new_contact_rows[list] = rows }
  end

  # Contacts de l'annuaire proposés pour une liste, dans l'état où le formulaire les a laissés.
  def directory_for(list)
    manager.contacts.select { |contact| contact.persisted? && contact.public_send(:"#{CONTACT_LISTS[list]}?") }
  end

  def launch!
    raise ActiveRecord::RecordInvalid, self unless launchable?

    transaction do
      running!
      respondents.each(&:invite!)
    end
  end

  def close!
    unless running?
      errors.add(:base, "La campagne n'est pas en cours")
      raise ActiveRecord::RecordInvalid, self
    end

    closed!
  end

  def accepting_answers?
    running? && deadline_on >= Date.current
  end

  # Évalué en base : l'association peut être chargée avant la dernière soumission.
  def all_submitted?
    !respondents.where(submitted_at: nil).exists?
  end

  # Clôture une campagne en cours dont tous les sondés ont soumis. La mise à jour est conditionnelle : si deux
  # soumissions arrivent ensemble, une seule clôture réussit et envoie l'e-mail au manager : celle-là rend true.
  def close_when_complete!
    return false unless running? && all_submitted?

    closed_now = self.class.running.where(id: id).update_all(status: self.class.statuses[:closed], updated_at: Time.current) == 1
    return false unless closed_now

    reload
    CampaignMailer.completed(self).deliver_later
    true
  end

  def launchable?
    errors.clear
    errors.add(:base, "La campagne a déjà été lancée") unless draft?
    errors.add(:subjects, :blank) if subjects.reject(&:marked_for_destruction?).empty?
    errors.add(:respondents, :blank) if respondents.reject(&:marked_for_destruction?).empty?
    errors.add(:questions, :blank) if questions.reject(&:marked_for_destruction?).empty?
    errors.empty?
  end

  private

  def contact_selection
    @contact_selection ||= {}
  end

  def new_contact_rows
    @new_contact_rows ||= {}
  end

  def new_contacts
    @new_contacts ||= Hash.new { |hash, list| hash[list] = [] }
  end

  def touched_contacts
    @touched_contacts ||= []
  end

  def selected_contact_ids(list)
    contact_selection.fetch(list) { public_send(list).reject(&:marked_for_destruction?).filter_map(&:contact_id) }
  end

  def assign_contacts
    CONTACT_LISTS.each_key do |list|
      next unless contact_selection.key?(list) || new_contact_rows.key?(list)

      ids = Array(contact_selection[list]).map(&:to_i)
      ids |= add_new_contacts(list).filter_map(&:id)
      contact_selection[list] = ids
      wanted = directory_for(list).select { |contact| ids.include?(contact.id) } +
               new_contacts[list].select { |contact| contact.new_record? && contact.valid? }
      sync_list(list, wanted)
    end
  end

  # Un e-mail déjà présent dans l'annuaire reprend ce contact, en lui ajoutant le rôle de la liste.
  def add_new_contacts(list)
    role = CONTACT_LISTS[list]
    rows = new_contact_rows.fetch(list, [])
    rows = rows.values if rows.respond_to?(:values)
    new_contacts[list] = rows.filter_map do |row|
      name, email = row.to_h.stringify_keys.values_at("name", "email").map { |value| value.to_s.strip }
      next if name.empty? && email.empty?

      contact = touched_contacts.find { |known| known.email == email.downcase } ||
                manager.contacts.find { |known| known.email == email.downcase } ||
                manager.contacts.build(name: name, email: email)
      contact.public_send(:"#{role}=", true)
      touched_contacts << contact unless touched_contacts.include?(contact)
      contact
    end
  end

  # Idempotent : la validation peut tourner plusieurs fois avant l'enregistrement.
  def sync_list(list, wanted)
    rows = public_send(list)
    copy_of = ->(row, contact) { contact.persisted? ? row.contact_id == contact.id : row.association(:contact).target.equal?(contact) }
    rows.each do |row|
      row.mark_for_destruction unless wanted.any? { |contact| copy_of.(row, contact) }
    end
    wanted.each do |contact|
      rows.build(contact: contact, name: contact.name, email: contact.email) unless rows.any? { |row| copy_of.(row, contact) }
    end
  end

  def new_contacts_valid
    touched_contacts.reject(&:valid?).each do |contact|
      errors.add(:base, "Nouveau contact « #{contact.name.presence || contact.email} » : #{contact.errors.full_messages.to_sentence}")
    end
  end

  def save_touched_contacts
    touched_contacts.each(&:save!)
  end

  def renumber_questions
    return unless questions.any?(&:changed_for_autosave?)

    questions.reject(&:marked_for_destruction?).each_with_index do |question, index|
      question.position = index
    end
  end

  def deadline_in_future
    errors.add(:deadline_on, :greater_than, count: Date.current) if deadline_on && deadline_on <= Date.current
  end

  def content_frozen_once_launched
    return if status_changed? || draft?

    frozen_change = subjects.any?(&:changed_for_autosave?) || respondents.any?(&:changed_for_autosave?) ||
                    questions.any?(&:changed_for_autosave?)
    errors.add(:base, "Les managés, sondés et questions ne sont plus modifiables après le lancement") if frozen_change
  end
end
