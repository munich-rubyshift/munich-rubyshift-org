class Avo::Resources::LocationsCity < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::City
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :state_code, as: :text, sortable: true
    field :country_code, as: :text, sortable: true
    field :coordinates, as: :belongs_to, **belongs_to_field_options(:coordinates)
  end
end
