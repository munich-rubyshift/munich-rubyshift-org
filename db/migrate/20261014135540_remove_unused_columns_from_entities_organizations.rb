class RemoveUnusedColumnsFromEntitiesOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :entities_organizations, :description, :text
    remove_column :entities_organizations, :main_location, :string
    remove_column :entities_organizations, :logo_background, :string
  end
end
