class Events::ParticipationsController < ApplicationController
  def index
    @events_participations = Events::Participation.all
  end

  def show
    @events_participation = Events::Participation.find(params.expect(:id))
  end
end
