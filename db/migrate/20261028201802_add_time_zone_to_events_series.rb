class AddTimeZoneToEventsSeries < ActiveRecord::Migration[8.1]
  def change
    add_column :events_series, :time_zone, :string
    change_column_null :events_series, :time_zone, false, "Europe/Berlin"
  end
end
