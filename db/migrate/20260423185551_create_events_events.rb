class CreateEventsEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events_events, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :title
      t.string :rubyevents_slug
      t.references :venues_venue, null: false, foreign_key: true, type: :string
      t.text :description
      t.string :kind
      t.boolean :hybrid
      t.string :status
      t.boolean :last_edition
      t.date :start_date
      t.date :end_date
      t.datetime :published_at
      t.date :announced_on
      t.integer :year
      t.string :date_precision
      t.string :frequency
      t.string :channel_id
      t.string :playlist
      t.string :website
      t.string :twitter
      t.string :mastodon
      t.string :github
      t.string :meetup
      t.string :luma
      t.string :youtube
      t.string :tickets_url
      t.string :banner_background
      t.string :featured_background
      t.string :featured_color
      t.boolean :online_event

      t.timestamps
    end
  end
end
