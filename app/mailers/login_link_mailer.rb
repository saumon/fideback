class LoginLinkMailer < ApplicationMailer
  def link(login_link)
    manager = login_link.manager
    @name = manager.name
    @url = manager_login_link_url(token: login_link.token)
    @minutes = (LoginLink::VALIDITY / 1.minute).to_i

    mail to: email_address_with_name(manager.email, manager.name), subject: "Votre lien de connexion à Fideback"
  end
end
