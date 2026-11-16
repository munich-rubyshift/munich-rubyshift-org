class CreateListedSponsors < ActiveRecord::Migration[8.1]
  def change
    create_view :events_meetup_hosts
    create_view :sponsors_listed_sponsor_tiers
    create_view :sponsors_listed_sponsorships
  end
end
