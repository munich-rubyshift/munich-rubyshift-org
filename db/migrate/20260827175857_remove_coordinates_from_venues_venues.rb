class RemoveCoordinatesFromVenuesVenues < ActiveRecord::Migration[8.1]
  def change
    remove_reference :venues_venues, :locations_coordinates, null: false, foreign_key: true, type: :string
  end
end
