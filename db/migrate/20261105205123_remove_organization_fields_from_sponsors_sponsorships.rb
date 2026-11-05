class RemoveOrganizationFieldsFromSponsorsSponsorships < ActiveRecord::Migration[8.1]
  def change
    remove_column :sponsors_sponsorships, :description, :text
    remove_column :sponsors_sponsorships, :logo_url, :string
    remove_column :sponsors_sponsorships, :name, :string
    remove_column :sponsors_sponsorships, :rubyevents_slug, :string
    remove_column :sponsors_sponsorships, :slug, :string
    remove_column :sponsors_sponsorships, :website, :string
  end
end
