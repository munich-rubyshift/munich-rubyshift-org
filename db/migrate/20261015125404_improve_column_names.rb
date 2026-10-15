class ImproveColumnNames < ActiveRecord::Migration[8.1]
  def change
    rename_column :entities_people, :github, :github_username
    rename_column :entities_people, :twitter, :twitter_username
    rename_column :entities_people, :bluesky, :bluesky_handle
    rename_column :entities_people, :linkedin, :linkedin_username
    rename_column :entities_people, :speakerdeck, :speakerdeck_username

    rename_column :events_series, :twitter, :twitter_username
    rename_column :events_series, :bsky, :bluesky_handle

    rename_column :events_events, :twitter, :twitter_username

    rename_column :venues_venues, :url, :website
  end
end
