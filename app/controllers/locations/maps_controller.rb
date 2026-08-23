class Locations::MapsController < ApplicationController
  def index
    @locations_maps = Locations::Map.all
  end

  def show
    @locations_map = Locations::Map.find(params.expect(:id))
  end
end
