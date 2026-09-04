class Avo::Resources::EntitiesOrganization < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Entities::Organization
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :description, as: :textarea
    field :website, as: :text, sortable: true
    field :logo_background, as: :text, sortable: true
    field :logo_url, as: :text, sortable: true
    field :main_location, as: :text, sortable: true
  end
end
