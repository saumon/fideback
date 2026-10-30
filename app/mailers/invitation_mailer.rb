class InvitationMailer < ApplicationMailer
  def invitation(invitation)
    @invitation = invitation
    @inviter_name = invitation.invited_by&.name || "Un administrateur"
    @url = invitation_acceptance_url(token: invitation.token)
    @valid_until = I18n.l(invitation.expires_at.to_date, format: :long)

    mail to: email_address_with_name(invitation.email, invitation.name),
         subject: "#{@inviter_name} vous invite à rejoindre Fideback"
  end
end
