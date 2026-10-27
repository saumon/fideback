class RespondentMailer < ApplicationMailer
  def invitation(respondent)
    @respondent = respondent
    @campaign = respondent.campaign
    @manager = @campaign.manager
    @url = respondent_form_url(token: respondent.token)

    mail to: email_address_with_name(respondent.email, respondent.name),
         subject: "#{@manager.name} vous demande un feedback : #{@campaign.name}"
  end
end
