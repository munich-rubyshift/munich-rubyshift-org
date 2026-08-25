class RemoveFrequencyFromEventsEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events_events, :frequency, :string
  end
end
