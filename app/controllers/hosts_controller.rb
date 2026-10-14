class HostsController < ApplicationController
  def index
    @hosts = Entities::Organization.meetup_hosts
  end
end
