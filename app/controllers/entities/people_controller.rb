class Entities::PeopleController < ApplicationController
  def index
    @entities_people = Entities::Person.all
  end

  def show
    @entities_person = Entities::Person.find(params.expect(:id))
  end
end
