class Avo::Resources::VenuesVenue < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Venues::Venue
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :description, as: :textarea
    field :url, as: :text, sortable: true
    field :instructions, as: :textarea
    field :accessibility_wheelchair, as: :boolean, sortable: true
    field :accessibility_elevators, as: :boolean, sortable: true
    field :accessibility_restrooms, as: :boolean, sortable: true
    field :accessibility_notes, as: :textarea
    field :nearby_public_transport, as: :textarea
    field :nearby_parking, as: :textarea
    field :address, as: :belongs_to, **belongs_to_field_options(:address)
    field :map, as: :belongs_to, **belongs_to_field_options(:map)
  end
end
