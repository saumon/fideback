class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show edit update destroy launch close]

  def index
    @campaigns = current_manager.campaigns.order(created_at: :desc)
  end

  def show
    @respondents = @campaign.respondents.includes(:answers).order(:name)
    @subjects = @campaign.subjects.order(:name)
  end

  def new
    @campaign = current_manager.campaigns.build(deadline_on: 1.month.from_now.to_date)
    @campaign.build_default_questions
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
