class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show edit update destroy launch close]
  before_action :set_templates, only: %i[new create]

  def index
    @campaigns = current_manager.campaigns.order(created_at: :desc)
  end

  def show
    @respondents = @campaign.respondents.includes(:answers).order(:name)
    @subjects = @campaign.subjects.order(:name)
  end

  def new
    @campaign = current_manager.campaigns.build(deadline_on: 1.month.from_now.to_date)
    @template.build_questions_for(@campaign)
  end

  def create
    @campaign = current_manager.campaigns.build(campaign_params)
    if @campaign.save
      redirect_to @campaign, notice: "Campagne créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to @campaign, alert: "Une campagne lancée n'est plus modifiable." unless @campaign.draft?
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: "Campagne mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return redirect_to @campaign, alert: "Cette campagne est en cours : clôturez-la avant de la supprimer.", status: :see_other unless @campaign.deletable?

    @campaign.destroy
    redirect_to campaigns_path, notice: "Campagne supprimée.", status: :see_other
  end

  def launch
    @campaign.launch!
    redirect_to @campaign, notice: "Campagne lancée : les invitations sont envoyées.", status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to @campaign, alert: @campaign.errors.full_messages.to_sentence, status: :see_other
  end

  def close
    @campaign.close!
    redirect_to @campaign, notice: "Campagne clôturée.", status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to @campaign, alert: @campaign.errors.full_messages.to_sentence, status: :see_other
  end

  private

  # Les modèles proposés à la création, et celui qui est choisi : le modèle par défaut si aucun, ou si l'identifiant
  # n'est pas celui d'un modèle du manager. Le choix est aussi renvoyé avec un formulaire refusé, qui garde ainsi le sélecteur.
  def set_templates
    @templates = QuestionTemplate.available_to(current_manager).includes(:items)
    @template = @templates.find { |template| template.id.to_s == params[:template_id].to_s } || @templates.find(&:system?)
  end

  def set_campaign
    @campaign = current_manager.campaigns.find(params[:id])
  end

  def campaign_params
    params.expect(campaign: [
      :name, :deadline_on,
      subject_contact_ids: [], respondent_contact_ids: [],
      new_subject_contacts: [ [ :name, :email ] ], new_respondent_contacts: [ [ :name, :email ] ],
      questions_attributes: [ [ :id, :position, :prompt, :rating, :comment, :_destroy ] ]
    ])
  end
end
