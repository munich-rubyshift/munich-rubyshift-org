class ReplaceEventOnlineFlagsWithAttendanceMode < ActiveRecord::Migration[8.1]
  def change
    add_column :events_events, :attendance_mode, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE events_events SET attendance_mode = CASE
            WHEN hybrid THEN 'hybrid'
            WHEN online_event THEN 'online'
            ELSE 'in_person'
          END
        SQL
      end

      direction.down do
        execute <<~SQL.squish
          UPDATE events_events SET
            hybrid = (attendance_mode = 'hybrid'),
            online_event = (attendance_mode IN ('hybrid', 'online'))
        SQL
      end
    end

    change_column_null :events_events, :attendance_mode, false

    remove_column :events_events, :hybrid, :boolean
    remove_column :events_events, :online_event, :boolean
  end
end
