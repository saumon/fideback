class AddPurposeToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :purpose, :text
  end
end
