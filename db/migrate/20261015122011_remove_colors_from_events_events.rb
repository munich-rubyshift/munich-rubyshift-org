class RemoveColorsFromEventsEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events_events, :banner_background, :string
    remove_column :events_events, :featured_background, :string
    remove_column :events_events, :featured_color, :string
  end
end
