class AddLocationsToVenuesVenues < ActiveRecord::Migration[8.1]
  def change
    add_reference :venues_venues, :locations_address, null: false, foreign_key: true, type: :string
    add_reference :venues_venues, :locations_coordinates, null: false, foreign_key: true, type: :string
    add_reference :venues_venues, :locations_map, foreign_key: true, type: :string
  end
end
