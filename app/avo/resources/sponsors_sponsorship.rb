class Avo::Resources::SponsorsSponsorship < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Sponsors::Sponsorship
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :organization, as: :belongs_to
    field :sponsor_tier, as: :belongs_to
    field :description, as: :textarea
    field :website, as: :text
    field :logo_url, as: :text
    field :badge, as: :text
  end
end
