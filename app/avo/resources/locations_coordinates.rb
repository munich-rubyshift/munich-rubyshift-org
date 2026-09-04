class Avo::Resources::LocationsCoordinates < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Coordinates
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.default_sort_column = :latitude
  self.default_sort_direction = :desc

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    # Longitude breaks the tie so coordinates on the same parallel still come
    # out west to east. This is also what makes the default sort two-column.
    field :latitude, as: :text, sortable: -> { query.order(latitude: direction, longitude: :asc) }
    field :longitude, as: :text, sortable: true
  end
end
