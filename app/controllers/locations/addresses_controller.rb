class Locations::AddressesController < ApplicationController
  def index
    @locations_addresses = Locations::Address.all
  end

  def show
    @locations_address = Locations::Address.find(params.expect(:id))
  end
end
