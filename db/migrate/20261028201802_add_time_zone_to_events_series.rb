class AddTimeZoneToEventsSeries < ActiveRecord::Migration[8.1]
  def change
    add_column :events_series, :time_zone, :string, null: false
  end
end
