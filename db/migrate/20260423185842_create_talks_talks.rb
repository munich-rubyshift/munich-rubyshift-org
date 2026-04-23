class CreateTalksTalks < ActiveRecord::Migration[8.1]
  def change
    create_table :talks_talks, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :title
      t.string :rubyevents_slug
      t.references :events_event, null: false, foreign_key: true, type: :string
      t.text :description
      t.string :raw_title
      t.string :original_title
      t.string :slides_url
      t.string :external_id
      t.string :kind
      t.string :status
      t.date :date
      t.time :time
      t.datetime :published_at
      t.datetime :announced_at
      t.string :removed
      t.string :location
      t.string :video_provider
      t.string :video_id
      t.boolean :external_player
      t.string :external_player_url
      t.string :track
      t.string :language

      t.timestamps
    end
  end
end
