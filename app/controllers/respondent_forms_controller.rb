# Espace public d'un sondé : accès par jeton personnel, sans compte.
class RespondentFormsController < ApplicationController
  skip_before_action :authenticate_manager!
  before_action :set_respondent

  layout "respondent"

  def show
    @input = nil
  end

  def update
    return render_closed unless writable?

    if @respondent.save_answers(answers_params)
      redirect_to respondent_form_path(token: @respondent.token), notice: "Vos réponses sont enregistrées.", status: :see_other
    else
      @input = answers_params
      flash.now[:alert] = "Certaines réponses sont invalides (une note doit être comprise entre 1 et 5)."
      render :show, status: :unprocessable_entity
    end
  end

  def submit
    return render_closed unless writable?

    unless @respondent.save_answers(answers_params)
      @input = answers_params
      flash.now[:alert] = "Certaines réponses sont invalides (une note doit être comprise entre 1 et 5)."
      return render :show, status: :unprocessable_entity
    end

    if @respondent.submit!
      redirect_to respondent_form_path(token: @respondent.token), notice: "Merci ! Vos réponses ont été soumises.", status: :see_other
    else
      @input = answers_params
      @missing = @respondent.missing_ratings
      flash.now[:alert] = "Il manque des notes : complétez les champs signalés avant de soumettre."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_respondent
    @respondent = Respondent.includes(campaign: :manager).find_by!(token: params[:token])
    @campaign = @respondent.campaign
  end

  def writable?
    @campaign.accepting_answers? && !@respondent.submitted?
  end

  def render_closed
    redirect_to respondent_form_path(token: @respondent.token), alert: "Cette campagne n'accepte plus de réponses.", status: :see_other
  end

  def answers_params
    raw = params.fetch(:answers, {})
    raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h.transform_values { |per_question| per_question.to_h } : {}
  end

  helper_method :input_value
  def input_value(subject, question, field)
    if @input
      @input.dig(subject.id.to_s, question.id.to_s, field.to_s)
    else
      answer = answers_by_key[[ subject.id, question.id ]]
      answer&.public_send(field)
    end
  end

  def answers_by_key
    @answers_by_key ||= @respondent.answers.index_by { |answer| [ answer.subject_id, answer.question_id ] }
  end
end
