class AddPositionToTalksTalks < ActiveRecord::Migration[8.1]
  def change
    add_column :talks_talks, :position, :integer

    # Order talks by title
    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE talks_talks SET position = numbered.position
          FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY events_event_id ORDER BY title) AS position
            FROM talks_talks
          ) AS numbered
          WHERE talks_talks.id = numbered.id
        SQL
      end
    end

    change_column_null :talks_talks, :position, false

    remove_index :talks_talks, :events_event_id
    add_index :talks_talks, [ :events_event_id, :position ], unique: true
  end
end
