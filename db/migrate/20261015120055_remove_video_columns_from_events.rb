class RemoveVideoColumnsFromEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events_events, :channel_id, :string
    remove_column :events_events, :playlist, :string
    remove_column :events_events, :youtube, :string

    remove_column :events_series, :vimeo, :string
    remove_column :events_series, :youtube_channel_id, :string
    remove_column :events_series, :youtube_channel_name, :string
    remove_column :events_series, :youtube_channel_handle, :string
    remove_column :events_series, :playlist_matcher, :string
  end
end
