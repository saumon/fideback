# Invitations de nouveaux managers, par l'Admin. Elles passent par un lien personnel : elles fonctionnent
# que les inscriptions soient ouvertes ou fermées.
class Admin::InvitationsController < Admin::BaseController
  before_action :set_invitation, only: %i[destroy resend]

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.invite(name: invitation_params[:name], email: invitation_params[:email], by: current_manager)

    if @invitation.errors.empty?
      redirect_to admin_users_path, notice: "Invitation envoyée à #{@invitation.email}.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    if @invitation.renew(by: current_manager)
      redirect_to admin_users_path, notice: "Invitation renvoyée à #{@invitation.email}.", status: :see_other
    else
      redirect_to admin_users_path, alert: "L'invitation ne peut plus être renvoyée à #{@invitation.email} : #{@invitation.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  def destroy
    @invitation.destroy!
    redirect_to admin_users_path, notice: "Invitation à #{@invitation.email} annulée.", status: :see_other
  end

  private

  def set_invitation
    @invitation = Invitation.unaccepted.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:name, :email)
  end
end
