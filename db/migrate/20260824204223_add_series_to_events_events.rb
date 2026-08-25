class AddSeriesToEventsEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :events_events, :events_series, null: false, foreign_key: true, type: :string
  end
end
