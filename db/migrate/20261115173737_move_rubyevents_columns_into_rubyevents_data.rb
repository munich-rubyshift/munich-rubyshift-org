class MoveRubyeventsColumnsIntoRubyeventsData < ActiveRecord::Migration[8.1]
  STRINGS = {
    entities_people: { rubyevents_slug: :slug },
    events_events: { rubyevents_slug: :slug },
    events_series: {
      rubyevents_slug: :slug,
      banner_background: :banner_background,
      featured_background: :featured_background,
      featured_color: :featured_color,
      frequency: :frequency
    },
    locations_cities: { rubyevents_slug: :slug },
    sponsors_sponsor_tiers: { rubyevents_slug: :slug },
    talks_talks: { rubyevents_slug: :slug },
    venues_venues: { rubyevents_slug: :slug }
  }.freeze

  def up
    STRINGS.each do |table, keys|
      keys.each do |column, key|
        insert_key table, key, column
        remove_column table, column, :string
      end
    end

    insert_key :events_series, :inactive, "json(iif(ended, 'true', 'false'))"
    remove_column :events_series, :ended, :boolean, default: false, null: false
  end

  def down
    add_column :events_series, :ended, :boolean, default: false, null: false
    extract_key :events_series, :inactive, into: :ended

    STRINGS.each do |table, keys|
      keys.each do |column, key|
        add_column table, column, :string
        extract_key table, key, into: column
      end

      execute "UPDATE #{table} SET rubyevents_data = NULL WHERE rubyevents_data = '{}'"
    end
  end

  private

  # A key already in the RubyEvents data wins.
  def insert_key(table, key, value)
    execute <<~SQL
      UPDATE #{table} SET rubyevents_data = json_insert(coalesce(rubyevents_data, '{}'), '$.#{key}', #{value})
      WHERE #{value} IS NOT NULL
    SQL
  end

  def extract_key(table, key, into:)
    execute <<~SQL
      UPDATE #{table} SET #{into} = rubyevents_data ->> '$.#{key}', rubyevents_data = json_remove(rubyevents_data, '$.#{key}')
      WHERE rubyevents_data ->> '$.#{key}' IS NOT NULL
    SQL
  end
end
