class RemoveUnusedColumnsFromTalksTalks < ActiveRecord::Migration[8.1]
  def change
    change_table :talks_talks, bulk: true do |t|
      t.remove :external_id, type: :string
      t.remove :raw_title, type: :string
      t.remove :original_title, type: :string
      t.remove :status, type: :string
      t.remove :removed, type: :string
      t.remove :location, type: :string
      t.remove :track, type: :string
      t.remove :date, type: :date
      t.remove :time, type: :time
      t.remove :video_provider, type: :string
      t.remove :video_id, type: :string
      t.remove :published_at, type: :datetime
      t.remove :external_player, type: :boolean
      t.remove :external_player_url, type: :string
    end
  end
end
