class Avo::Resources::EntitiesOrganization < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Entities::Organization
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :description, as: :textarea
    field :website, as: :text
    field :logo_background, as: :text
    field :logo_url, as: :text
    field :main_location, as: :text
  end
end
