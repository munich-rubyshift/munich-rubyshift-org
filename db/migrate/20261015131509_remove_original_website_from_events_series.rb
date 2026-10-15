class RemoveOriginalWebsiteFromEventsSeries < ActiveRecord::Migration[8.1]
  def change
    remove_column :events_series, :original_website, :string
  end
end
