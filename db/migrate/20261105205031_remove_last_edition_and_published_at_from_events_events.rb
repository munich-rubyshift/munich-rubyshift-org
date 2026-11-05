class RemoveLastEditionAndPublishedAtFromEventsEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events_events, :last_edition, :boolean, default: false, null: false
    remove_column :events_events, :published_at, :datetime
  end
end
