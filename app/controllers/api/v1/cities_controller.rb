class Api::V1::CitiesController < Api::V1::ApplicationController
  def index
    cities = Locations::City.includes(:coordinates).order(:slug)
    render_list cities.map { |city| Api::V1::CitySerializer.new(city).resource }
  end
end
