class TeamsController < ApplicationController
  before_action :set_manager

  def show
    build_blank_row
  end

  def update
    if @manager.update(team_params)
      redirect_to team_path, notice: "Équipe enregistrée."
    else
      build_blank_row
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_manager
    @manager = current_manager
  end

  def build_blank_row
    @manager.contacts.build unless @manager.contacts.any?(&:new_record?)
  end

  # Un identifiant qui n'est pas dans l'annuaire du manager est ignoré, ligne comprise.
  def team_params
    permitted = params.expect(manager: [ contacts_attributes: [ [ :id, :name, :email, :managed, :surveyable, :_destroy ] ] ])
    own_ids = @manager.contacts.ids.map(&:to_s)
    rows = permitted.fetch(:contacts_attributes, {}).to_h.select { |_, row| row["id"].blank? || own_ids.include?(row["id"].to_s) }
    { contacts_attributes: rows }
  end
end
