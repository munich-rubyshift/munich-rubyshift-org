class Avo::Resources::LocationsCoordinates < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Coordinates
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :latitude, as: :text
    field :longitude, as: :text
  end
end
