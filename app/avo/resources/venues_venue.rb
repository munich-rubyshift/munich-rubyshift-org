class Avo::Resources::VenuesVenue < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Venues::Venue
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.default_sort_column = :slug
  self.default_sort_direction = :asc

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :description, **LONG_FORM_TEXT_FIELD_OPTIONS
    field :website, as: :text, sortable: true
    field :instructions, **LONG_FORM_TEXT_FIELD_OPTIONS
    field :accessibility_wheelchair, as: :boolean, sortable: true
    field :accessibility_elevators, as: :boolean, sortable: true
    field :accessibility_restrooms, as: :boolean, sortable: true
    field :accessibility_notes, **LONG_FORM_TEXT_FIELD_OPTIONS
    field :nearby_public_transport, **LONG_FORM_TEXT_FIELD_OPTIONS
    field :nearby_parking, **LONG_FORM_TEXT_FIELD_OPTIONS
    field :address, as: :belongs_to, **sortable(:by_to_s, on: :address)
    field :map, as: :belongs_to, **sortable(:by_to_s, on: :map)
    field :organization, as: :belongs_to, **sortable(:by_to_s, on: :organization), attach_scope: -> { query.by_to_s }
  end
end
