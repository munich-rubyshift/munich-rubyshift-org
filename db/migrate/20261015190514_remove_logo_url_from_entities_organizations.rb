class RemoveLogoUrlFromEntitiesOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :entities_organizations, :logo_url, :string
  end
end
