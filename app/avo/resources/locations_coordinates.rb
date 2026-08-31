class Avo::Resources::LocationsCoordinates < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Coordinates
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :latitude, as: :text
    field :longitude, as: :text
  end
end
