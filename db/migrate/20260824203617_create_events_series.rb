class CreateEventsSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :events_series, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.text :description
      t.string :kind
      t.string :frequency
      t.boolean :ended
      t.string :default_country_code
      t.string :language
      t.string :website
      t.string :original_website
      t.string :twitter
      t.string :facebook
      t.string :mastodon
      t.string :bsky
      t.string :github
      t.string :linkedin
      t.string :meetup
      t.string :luma
      t.string :guild
      t.string :vimeo
      t.string :discord
      t.string :youtube_channel_id
      t.string :youtube_channel_name
      t.string :youtube_channel_handle
      t.string :playlist_matcher

      t.timestamps
    end
  end
end
