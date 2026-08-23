class Entities::PersonComponent < ApplicationComponent
  attr_reader :person

  def initialize(person)
    @person = person
  end
end
