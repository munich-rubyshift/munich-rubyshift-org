class RemoveWebsiteAndLogoUrlFromSponsorsSponsorships < ActiveRecord::Migration[8.1]
  def change
    remove_column :sponsors_sponsorships, :website, :string
    remove_column :sponsors_sponsorships, :logo_url, :string
  end
end
