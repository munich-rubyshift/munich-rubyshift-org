class CreateSponsorsSponsorships < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsors_sponsorships, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.references :entities_organization, null: false, foreign_key: true, type: :string
      t.references :sponsors_sponsor_tier, null: false, foreign_key: true, type: :string
      t.text :description
      t.string :website
      t.string :logo_url
      t.string :badge

      t.timestamps
    end
  end
end
