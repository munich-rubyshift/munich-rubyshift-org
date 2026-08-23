class CreateLocationsCoordinates < ActiveRecord::Migration[8.1]
  def change
    create_table :locations_coordinates, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
