class DefaultBooleansToFalse < ActiveRecord::Migration[8.1]
  BOOLEANS = {
    events_events: %i[last_edition],
    events_series: %i[ended],
    venues_venues: %i[accessibility_elevators accessibility_restrooms accessibility_wheelchair]
  }.freeze

  def change
    BOOLEANS.each do |table, columns|
      columns.each do |column|
        change_column_default table, column, from: nil, to: false
        change_column_null table, column, false, false
      end
    end
  end
end
