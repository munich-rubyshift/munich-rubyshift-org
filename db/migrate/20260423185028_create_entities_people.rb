class CreateEntitiesPeople < ActiveRecord::Migration[8.1]
  def change
    create_table :entities_people, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.string :github
      t.string :twitter
      t.string :website
      t.string :mastodon
      t.string :bluesky
      t.string :linkedin
      t.string :speakerdeck

      t.timestamps
    end
  end
end
