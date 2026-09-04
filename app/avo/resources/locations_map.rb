class Avo::Resources::LocationsMap < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Map
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :google_url, as: :text, sortable: true
    field :apple_url, as: :text, sortable: true
    field :openstreetmap_url, as: :text, sortable: true
  end
end
