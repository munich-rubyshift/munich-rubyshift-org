class Avo::Resources::EntitiesPerson < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Entities::Person
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :github, as: :text
    field :twitter, as: :text
    field :website, as: :text
    field :mastodon, as: :text
    field :bluesky, as: :text
    field :linkedin, as: :text
    field :speakerdeck, as: :text
  end
end
