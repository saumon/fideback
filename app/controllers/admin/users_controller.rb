# Les utilisateurs du site sont les managers : les sondés n'ont pas de compte. L'écran permet d'inviter de
# nouveaux managers, de suivre leurs invitations et de supprimer un manager ; il ne change ni rôle ni compte.
class Admin::UsersController < Admin::BaseController
  def index
    @managers = Manager.order(created_at: :desc, id: :desc)
    @campaign_counts = Campaign.group(:manager_id).count
    @invitations = Invitation.unaccepted.order(created_at: :desc, id: :desc)
  end

  # Supprime le manager avec ses campagnes (même en cours), leurs réponses, son annuaire et ses liens de connexion ;
  # les invitations qu'il a envoyées restent. Sa session cesse d'être valable puisque Devise ne le retrouve plus.
  # Un manager déjà supprimé donne un 404. L'Admin ne peut pas supprimer son propre compte, même par requête forgée.
  def destroy
    manager = Manager.find(params[:id])
    return redirect_to admin_users_path, alert: "Vous ne pouvez pas supprimer votre propre compte.", status: :see_other if manager == current_manager

    manager.destroy!
    redirect_to admin_users_path, notice: "#{manager.name} a été supprimé.", status: :see_other
  end
end
