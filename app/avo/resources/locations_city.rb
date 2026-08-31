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
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :state_code, as: :text
    field :country_code, as: :text
    field :coordinates, as: :belongs_to
  end
end
