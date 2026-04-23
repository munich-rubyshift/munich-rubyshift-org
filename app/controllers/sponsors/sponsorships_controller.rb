class Sponsors::SponsorshipsController < ApplicationController
  def index
    @sponsors_sponsorships = Sponsors::Sponsorship.all
  end

  def show
    @sponsors_sponsorship = Sponsors::Sponsorship.find(params.expect(:id))
  end
end
