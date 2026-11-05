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
    field :organization, as: :belongs_to, **sortable(:by_to_s, on: :organization)
    field :sponsor_tier, as: :belongs_to, **sortable(:by_to_s, on: :sponsor_tier)
    field :badge, as: :text, sortable: true
  end
end
