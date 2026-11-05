class AddColorsToEventsSeries < ActiveRecord::Migration[8.1]
  def change
    add_column :events_series, :banner_background, :string
    add_column :events_series, :featured_background, :string
    add_column :events_series, :featured_color, :string
  end
end
