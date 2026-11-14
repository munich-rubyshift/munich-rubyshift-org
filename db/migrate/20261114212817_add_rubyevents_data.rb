class AddRubyeventsData < ActiveRecord::Migration[8.1]
  TABLES = %i[
    entities_organizations entities_people events_cfps events_events events_involvements events_series
    locations_addresses locations_cities locations_maps sponsors_sponsor_tiers sponsors_sponsorships
    talks_additional_resources talks_talks venues_venues
  ].freeze

  def change
    TABLES.each { |table| add_column table, :rubyevents_data, :json }
  end
end
