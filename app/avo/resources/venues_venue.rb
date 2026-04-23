class Avo::Resources::VenuesVenue < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Venues::Venue
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :description, as: :textarea
    field :url, as: :text
    field :instructions, as: :textarea
    field :accessibility_wheelchair, as: :boolean
    field :accessibility_elevators, as: :boolean
    field :accessibility_restrooms, as: :boolean
    field :accessibility_notes, as: :textarea
    field :nearby_public_transport, as: :textarea
    field :nearby_parking, as: :textarea
  end
end
