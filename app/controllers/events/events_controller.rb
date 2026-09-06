class Events::EventsController < ApplicationController
  def index
    @events_events = Events::Event.all.order(start_date: :desc)
  end

  def show
    @events_event = Events::Event.find(params.expect(:id))
  end
end
