class RemoveTimestamps < ActiveRecord::Migration[8.1]
  TABLES = %i[
    entities_organizations
    entities_people
    events_cfps
    events_events
    events_involvements
    events_participations
    events_series
    locations_addresses
    locations_cities
    locations_coordinates
    locations_maps
    sponsors_sponsor_tiers
    sponsors_sponsorships
    talks_additional_resources
    talks_speaker_talks
    talks_talks
    venues_venues
  ]

  def change
    TABLES.each { |table| remove_timestamps table }

    remove_column :friendly_id_slugs, :created_at, :datetime
    remove_column :active_storage_blobs, :created_at, :datetime, null: false
    remove_column :active_storage_attachments, :created_at, :datetime, null: false
  end
end
