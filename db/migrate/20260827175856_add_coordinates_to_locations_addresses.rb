class AddCoordinatesToLocationsAddresses < ActiveRecord::Migration[8.1]
  def change
    add_reference :locations_addresses, :locations_coordinates, null: false, foreign_key: true, type: :string
  end
end
