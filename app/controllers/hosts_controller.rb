class HostsController < ApplicationController
  def index
    @hosts = Entities::Organization.meetup_hosts.with_attached_logo
  end
end
