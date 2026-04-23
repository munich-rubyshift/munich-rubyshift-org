class Talks::TalksController < ApplicationController
  def index
    @talks_talks = Talks::Talk.all
  end

  def show
    @talks_talk = Talks::Talk.find(params.expect(:id))
  end
end
