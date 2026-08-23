class Avo::Resources::LocationsAddress < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Address
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :street, as: :text
    field :zip_code, as: :text
    field :locations_city, as: :belongs_to
  end
end
