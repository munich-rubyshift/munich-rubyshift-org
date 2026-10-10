class Talks::TalksController < ApplicationController
  def index
    @talks_talks = Talks::Talk.joins(:event).order(events_events: { start_date: :desc }, position: :desc)
  end

  def show
    @talks_talk = Talks::Talk.find(params.expect(:id))
  end
end
