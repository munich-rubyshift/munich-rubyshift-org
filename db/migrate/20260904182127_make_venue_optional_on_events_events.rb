class MakeVenueOptionalOnEventsEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :events_events, :venues_venue_id, true
  end
end
