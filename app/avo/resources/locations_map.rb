class Avo::Resources::LocationsMap < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Map
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :google_url, as: :text
    field :apple_url, as: :text
    field :openstreetmap_url, as: :text
  end
end
