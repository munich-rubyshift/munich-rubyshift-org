class CreateVenuesVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues_venues, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.text :description
      t.string :url
      t.text :instructions
      t.boolean :accessibility_wheelchair
      t.boolean :accessibility_elevators
      t.boolean :accessibility_restrooms
      t.text :accessibility_notes
      t.text :nearby_public_transport
      t.text :nearby_parking

      t.timestamps
    end
  end
end
