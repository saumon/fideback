# Acceptation d'une invitation, depuis le lien reçu par e-mail. Sans compte requis, et sans la garde des
# inscriptions fermées : l'invitation est précisément le moyen d'entrer alors qu'elles le sont.
class InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate_manager!
  before_action :redirect_signed_in_manager
  before_action :set_invitation

  def show
    @manager = Manager.new(name: @invitation.name, email: @invitation.email)
  end

  def update
    @manager = @invitation.accept(**acceptance_params)

    if @manager.persisted?
      redirect_to new_manager_session_path, notice: "Votre compte est créé. Connectez-vous pour commencer.", status: :see_other
    elsif @manager.errors.include?(:email)
      # L'adresse a obtenu un compte entre-temps.
      render :invalid, status: :not_found
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def redirect_signed_in_manager
    redirect_to campaigns_path, alert: I18n.t("devise.failure.already_authenticated") if manager_signed_in?
  end

  # Un lien inconnu, expiré, annulé, remplacé ou déjà utilisé donne la même page : l'invité doit de toute façon
  # demander une nouvelle invitation, et rien n'indique si le jeton a existé.
  def set_invitation
    @invitation = Invitation.unaccepted.find_by(token: params[:token])
    render :invalid, status: :not_found unless @invitation&.acceptable?
  end

  def acceptance_params
    params.require(:manager).permit(:name, :password, :password_confirmation).to_h.symbolize_keys
  end
end
