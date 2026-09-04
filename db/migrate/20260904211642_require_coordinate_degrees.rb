class RequireCoordinateDegrees < ActiveRecord::Migration[8.1]
  def change
    change_column_null :locations_coordinates, :latitude, false
    change_column_null :locations_coordinates, :longitude, false
  end
end
