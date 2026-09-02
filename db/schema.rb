# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_04_182127) do
  create_table "active_storage_attachments", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "blob_id", limit: 36, null: false
    t.string "name", null: false
    t.string "record_id", limit: 36, null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "blob_id", limit: 36, null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "entities_organizations", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.text "description"
    t.string "logo_background"
    t.string "logo_url"
    t.string "main_location"
    t.string "name"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "website"
  end

  create_table "entities_people", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "bluesky"
    t.string "github"
    t.string "linkedin"
    t.string "mastodon"
    t.string "name"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "speakerdeck"
    t.string "twitter"
    t.string "website"
  end

  create_table "events_cfps", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.date "close_date"
    t.string "events_event_id", null: false
    t.string "external_url"
    t.string "name"
    t.date "open_date"
    t.string "slug"
    t.index ["events_event_id"], name: "index_events_cfps_on_events_event_id"
  end

  create_table "events_events", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.date "announced_on"
    t.string "attendance_mode", null: false
    t.string "banner_background"
    t.string "channel_id"
    t.string "date_precision"
    t.text "description"
    t.date "end_date"
    t.string "events_series_id", null: false
    t.string "featured_background"
    t.string "featured_color"
    t.string "github"
    t.string "kind"
    t.boolean "last_edition"
    t.string "luma"
    t.string "mastodon"
    t.string "meetup"
    t.string "playlist"
    t.datetime "published_at"
    t.string "rubyevents_slug"
    t.string "slug"
    t.date "start_date"
    t.string "status"
    t.string "tickets_url"
    t.string "title"
    t.string "twitter"
    t.string "venues_venue_id"
    t.string "website"
    t.integer "year"
    t.string "youtube"
    t.index ["events_series_id"], name: "index_events_events_on_events_series_id"
    t.index ["venues_venue_id"], name: "index_events_events_on_venues_venue_id"
  end

  create_table "events_involvements", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "entity_id", null: false
    t.string "entity_type", null: false
    t.string "events_event_id", null: false
    t.string "role"
    t.index ["entity_type", "entity_id"], name: "index_events_involvements_on_entity"
    t.index ["events_event_id"], name: "index_events_involvements_on_events_event_id"
  end

  create_table "events_participations", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "attended_as"
    t.string "entities_person_id", null: false
    t.string "events_event_id", null: false
    t.index ["entities_person_id"], name: "index_events_participations_on_entities_person_id"
    t.index ["events_event_id"], name: "index_events_participations_on_events_event_id"
  end

  create_table "events_series", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "bsky"
    t.string "default_country_code"
    t.text "description"
    t.string "discord"
    t.boolean "ended"
    t.string "facebook"
    t.string "frequency"
    t.string "github"
    t.string "guild"
    t.string "kind"
    t.string "language"
    t.string "linkedin"
    t.string "luma"
    t.string "mastodon"
    t.string "meetup"
    t.string "name"
    t.string "original_website"
    t.string "playlist_matcher"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "twitter"
    t.string "vimeo"
    t.string "website"
    t.string "youtube_channel_handle"
    t.string "youtube_channel_id"
    t.string "youtube_channel_name"
  end

  create_table "friendly_id_slugs", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "scope"
    t.string "slug", null: false
    t.string "sluggable_id", limit: 36, null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "locations_addresses", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "locations_city_id", null: false
    t.string "locations_coordinates_id", null: false
    t.string "slug"
    t.string "street"
    t.string "zip_code"
    t.index ["locations_city_id"], name: "index_locations_addresses_on_locations_city_id"
    t.index ["locations_coordinates_id"], name: "index_locations_addresses_on_locations_coordinates_id"
  end

  create_table "locations_cities", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "country_code"
    t.string "locations_coordinates_id", null: false
    t.string "name"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "state_code"
    t.index ["locations_coordinates_id"], name: "index_locations_cities_on_locations_coordinates_id", unique: true
  end

  create_table "locations_coordinates", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
  end

  create_table "locations_maps", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "apple_url"
    t.string "google_url"
    t.string "openstreetmap_url"
  end

  create_table "sponsors_sponsor_tiers", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.text "description"
    t.string "events_event_id", null: false
    t.integer "level"
    t.string "name"
    t.string "rubyevents_slug"
    t.string "slug"
    t.index ["events_event_id"], name: "index_sponsors_sponsor_tiers_on_events_event_id"
  end

  create_table "sponsors_sponsorships", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "badge"
    t.text "description"
    t.string "entities_organization_id", null: false
    t.string "logo_url"
    t.string "name"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "sponsors_sponsor_tier_id", null: false
    t.string "website"
    t.index ["entities_organization_id"], name: "index_sponsors_sponsorships_on_entities_organization_id"
    t.index ["sponsors_sponsor_tier_id"], name: "index_sponsors_sponsorships_on_sponsors_sponsor_tier_id"
  end

  create_table "talks_additional_resources", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "kind"
    t.string "name"
    t.string "talks_talk_id", null: false
    t.string "title"
    t.string "url"
    t.index ["talks_talk_id"], name: "index_talks_additional_resources_on_talks_talk_id"
  end

  create_table "talks_speaker_talks", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.string "entities_person_id", null: false
    t.string "talks_talk_id", null: false
    t.index ["entities_person_id"], name: "index_talks_speaker_talks_on_entities_person_id"
    t.index ["talks_talk_id"], name: "index_talks_speaker_talks_on_talks_talk_id"
  end

  create_table "talks_talks", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.datetime "announced_at"
    t.date "date"
    t.text "description"
    t.string "events_event_id", null: false
    t.string "external_id"
    t.boolean "external_player"
    t.string "external_player_url"
    t.string "kind"
    t.string "language"
    t.string "location"
    t.string "original_title"
    t.datetime "published_at"
    t.string "raw_title"
    t.string "removed"
    t.string "rubyevents_slug"
    t.string "slides_url"
    t.string "slug"
    t.string "status"
    t.time "time"
    t.string "title"
    t.string "track"
    t.string "video_id"
    t.string "video_provider"
    t.index ["events_event_id"], name: "index_talks_talks_on_events_event_id"
  end

  create_table "venues_venues", id: { type: :string, limit: 36, default: -> { "uuid()" } }, force: :cascade do |t|
    t.boolean "accessibility_elevators"
    t.text "accessibility_notes"
    t.boolean "accessibility_restrooms"
    t.boolean "accessibility_wheelchair"
    t.text "description"
    t.text "instructions"
    t.string "locations_address_id", null: false
    t.string "locations_map_id"
    t.string "name"
    t.text "nearby_parking"
    t.text "nearby_public_transport"
    t.string "rubyevents_slug"
    t.string "slug"
    t.string "url"
    t.index ["locations_address_id"], name: "index_venues_venues_on_locations_address_id"
    t.index ["locations_map_id"], name: "index_venues_venues_on_locations_map_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events_cfps", "events_events"
  add_foreign_key "events_events", "events_series"
  add_foreign_key "events_events", "venues_venues"
  add_foreign_key "events_involvements", "events_events"
  add_foreign_key "events_participations", "entities_people"
  add_foreign_key "events_participations", "events_events"
  add_foreign_key "locations_addresses", "locations_cities"
  add_foreign_key "locations_addresses", "locations_coordinates"
  add_foreign_key "locations_cities", "locations_coordinates"
  add_foreign_key "sponsors_sponsor_tiers", "events_events"
  add_foreign_key "sponsors_sponsorships", "entities_organizations"
  add_foreign_key "sponsors_sponsorships", "sponsors_sponsor_tiers"
  add_foreign_key "talks_additional_resources", "talks_talks"
  add_foreign_key "talks_speaker_talks", "entities_people"
  add_foreign_key "talks_speaker_talks", "talks_talks"
  add_foreign_key "talks_talks", "events_events"
  add_foreign_key "venues_venues", "locations_addresses"
  add_foreign_key "venues_venues", "locations_maps"
end
