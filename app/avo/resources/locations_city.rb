class Avo::Resources::LocationsCity < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::City
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :state_code, as: :text
    field :country_code, as: :text
    field :coordinates, as: :belongs_to
  end
end
