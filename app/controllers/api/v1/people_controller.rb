class Api::V1::PeopleController < Api::V1::ApplicationController
  def index
    people = Entities::Person.contributors.with_attached_avatar.order(:slug)
    render_document people.map { |person| Api::V1::PersonSerializer.new(person).resource }
  end
end
