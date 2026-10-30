# Remplit l'annuaire de chaque manager à partir des managés et sondés de ses campagnes :
# un contact par e-mail, au nom de sa ligne la plus récente, managé s'il a été managé
# et sondable s'il a été sondé. Relançable : seules les lignes sans contact sont reprises.
class BackfillContactsFromCampaigns < ActiveRecord::Migration[8.1]
  class Contact < ActiveRecord::Base
    self.table_name = "contacts"
  end

  class Subject < ActiveRecord::Base
    self.table_name = "subjects"
  end

  class Respondent < ActiveRecord::Base
    self.table_name = "respondents"
  end

  ROLES = { Subject => :managed, Respondent => :surveyable }.freeze

  def up
    managers = select_rows("SELECT id, manager_id FROM campaigns").to_h

    people = Hash.new { |hash, key| hash[key] = { rows: Hash.new { |rows, model| rows[model] = [] } } }
    rows = ROLES.keys.flat_map { |model| model.where(contact_id: nil).to_a }
    rows.sort_by { |row| [ row.created_at, row.class.name, row.id ] }.each do |row|
      person = people[[ managers.fetch(row.campaign_id), row.email.strip.downcase ]]
      person[:name] = row.name
      person[:rows][row.class] << row.id
    end

    people.each do |(manager_id, email), person|
      contact = Contact.find_or_initialize_by(manager_id: manager_id, email: email)
      contact.name = person[:name] if contact.new_record?
      person[:rows].each_key { |model| contact[ROLES.fetch(model)] = true }
      contact.save!
      person[:rows].each { |model, ids| model.where(id: ids).update_all(contact_id: contact.id) }
    end
  end

  # Les contacts disparaissent avec leur table, à l'annulation de la migration qui la crée.
  def down
  end
end
