class Events::InvolvementsController < ApplicationController
  def index
    @events_involvements = Events::Involvement.all
  end

  def show
    @events_involvement = Events::Involvement.find(params.expect(:id))
  end
end
