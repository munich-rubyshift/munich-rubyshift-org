class Entities::PeopleController < ApplicationController
  def index
    @entities_people = Entities::Person.with_talks
  end

  def show
    @entities_person = Entities::Person.find(params.expect(:id))
  end
end
