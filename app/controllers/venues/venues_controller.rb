class Venues::VenuesController < ApplicationController
  def index
    @venues_venues = Venues::Venue.all
  end

  def show
    @venues_venue = Venues::Venue.find(params.expect(:id))
  end
end
