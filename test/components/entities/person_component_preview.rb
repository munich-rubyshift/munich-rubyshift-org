class Entities::PersonComponentPreview < ViewComponent::Preview
  # Entities::Person
  # ---
  # Render a single Entities::Person
  #
  # @param person_slug [String] select {{ Entities::Person.pluck(:slug) }}
  def default(person_slug: "klaus-weidinger")
    person = Entities::Person.find_by!(slug: person_slug)
    render(Entities::PersonComponent.new(person))
  end
end
