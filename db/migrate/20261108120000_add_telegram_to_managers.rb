class AddTelegramToManagers < ActiveRecord::Migration[8.1]
  def change
    # Token chiffré par Active Record (texte : le chiffré est plus long que le token).
    add_column :managers, :telegram_bot_token, :text
    # Chaîne : un identifiant de conversation peut être négatif et dépasser 32 bits.
    add_column :managers, :telegram_chat_id, :string
    add_column :managers, :telegram_enabled, :boolean, default: false, null: false
  end
end
