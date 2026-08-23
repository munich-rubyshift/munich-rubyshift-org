class Locations::CoordinatesController < ApplicationController
  def index
    @locations_coordinates = Locations::Coordinates.all
  end

  def show
    @locations_coordinates = Locations::Coordinates.find(params.expect(:id))
  end
end
