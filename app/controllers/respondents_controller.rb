class RespondentsController < ApplicationController
  before_action :set_respondent

  def resend
    if @respondent.invitable?
      @respondent.invite!
      redirect_to @campaign, notice: "Invitation renvoyée à #{@respondent.name}.", status: :see_other
    else
      redirect_to @campaign, alert: "L'invitation ne peut plus être renvoyée à #{@respondent.name}.", status: :see_other
    end
  end

  private

  def set_respondent
    @campaign = current_manager.campaigns.find(params[:campaign_id])
    @respondent = @campaign.respondents.find(params[:id])
  end
end
