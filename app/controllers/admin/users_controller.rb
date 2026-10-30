# Les utilisateurs du site sont les managers : les sondés n'ont pas de compte. L'écran ne propose aucune
# action sur les comptes existants, seulement l'invitation de nouveaux managers et le suivi de leurs invitations.
class Admin::UsersController < Admin::BaseController
  def index
    @managers = Manager.order(created_at: :desc, id: :desc)
    @invitations = Invitation.unaccepted.order(created_at: :desc, id: :desc)
  end
end
