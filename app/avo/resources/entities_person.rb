class Avo::Resources::EntitiesPerson < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Entities::Person
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :github, as: :text, sortable: true
    field :twitter, as: :text, sortable: true
    field :website, as: :text, sortable: true
    field :mastodon, as: :text, sortable: true
    field :bluesky, as: :text, sortable: true
    field :linkedin, as: :text, sortable: true
    field :speakerdeck, as: :text, sortable: true
  end
end
