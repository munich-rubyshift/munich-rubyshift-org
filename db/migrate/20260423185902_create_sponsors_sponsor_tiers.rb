class CreateSponsorsSponsorTiers < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsors_sponsor_tiers, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.references :events_event, null: false, foreign_key: true, type: :string
      t.text :description
      t.integer :level

      t.timestamps
    end
  end
end
