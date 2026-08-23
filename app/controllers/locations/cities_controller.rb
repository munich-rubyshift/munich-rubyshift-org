class Locations::CitiesController < ApplicationController
  def index
    @locations_cities = Locations::City.all
  end

  def show
    @locations_city = Locations::City.find(params.expect(:id))
  end
end
