class MakeLocationsCitiesCoordinatesUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :locations_cities, :locations_coordinates_id
    add_index :locations_cities, :locations_coordinates_id, unique: true
  end
end
