class Sponsors::SponsorTiersController < ApplicationController
  def index
    @sponsors_sponsor_tiers = Sponsors::SponsorTier.all
  end

  def show
    @sponsors_sponsor_tier = Sponsors::SponsorTier.find(params.expect(:id))
  end
end
