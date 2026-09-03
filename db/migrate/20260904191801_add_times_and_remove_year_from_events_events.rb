class AddTimesAndRemoveYearFromEventsEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events_events, :start_time, :time
    add_column :events_events, :end_time, :time

    remove_column :events_events, :year, :integer
  end
end
