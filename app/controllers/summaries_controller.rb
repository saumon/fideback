class SummariesController < ApplicationController
  def show
    campaign = current_manager.campaigns.find(params[:campaign_id])
    @subject = campaign.subjects.find(params[:subject_id])
    @summary = SubjectSummary.new(@subject)
  end
end
