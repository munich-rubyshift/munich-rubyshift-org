class Events::SeriesController < ApplicationController
  def index
    @events_series = Events::Series.all
  end

  def show
    @events_series = Events::Series.find(params.expect(:id))
  end
end
