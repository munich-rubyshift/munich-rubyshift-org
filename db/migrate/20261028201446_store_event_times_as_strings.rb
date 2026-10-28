class StoreEventTimesAsStrings < ActiveRecord::Migration[8.1]
  COLUMNS = %i[start_time end_time].freeze

  def up
    COLUMNS.each do |column|
      change_column :events_events, column, :string
      execute "UPDATE events_events SET #{column} = substr(#{column}, 12, 5)"
      add_check_constraint :events_events, "#{column} GLOB '[01][0-9]:[0-5][0-9]' OR #{column} GLOB '2[0-3]:[0-5][0-9]'",
        name: "#{column}_format"
    end
  end

  def down
    COLUMNS.each do |column|
      remove_check_constraint :events_events, name: "#{column}_format"
      execute "UPDATE events_events SET #{column} = '2000-01-01 ' || #{column} || ':00'"
      change_column :events_events, column, :time
    end
  end
end
