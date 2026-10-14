class KeepLegalNameApartFromBrandOnEntitiesOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :entities_organizations, :legal_name, :string
    add_column :entities_organizations, :internal_notes, :text
    remove_column :entities_organizations, :rubyevents_slug, :string
  end
end
