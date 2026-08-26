class Talks::AdditionalResourcesController < ApplicationController
  def index
    @talks_additional_resources = Talks::AdditionalResource.all
  end

  def show
    @talks_additional_resource = Talks::AdditionalResource.find(params.expect(:id))
  end
end
