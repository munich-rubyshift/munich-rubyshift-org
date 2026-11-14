class Api::V1::CitiesController < Api::V1::ApplicationController
  def index
    cities = Locations::City.includes(:coordinates).order(:slug)
    render_list cities, serializer: Api::V1::CitySerializer
  end
end
