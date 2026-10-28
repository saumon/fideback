class AddLastInvitedAtToRespondents < ActiveRecord::Migration[8.1]
  # Valeurs de Campaign.statuses : running = 1, closed = 2.
  def up
    add_column :respondents, :last_invited_at, :datetime

    execute <<~SQL
      UPDATE respondents
      SET last_invited_at = (SELECT campaigns.updated_at FROM campaigns WHERE campaigns.id = respondents.campaign_id)
      WHERE campaign_id IN (SELECT id FROM campaigns WHERE status IN (1, 2))
    SQL
  end

  def down
    remove_column :respondents, :last_invited_at
  end
end
