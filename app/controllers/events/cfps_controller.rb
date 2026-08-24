class Events::CFPsController < ApplicationController
  def index
    @events_cfps = Events::CFP.all
  end

  def show
    @events_cfp = Events::CFP.find(params.expect(:id))
  end
end
