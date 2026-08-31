class Avo::Resources::EventsCFP < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::CFP
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, default: ::Events::CFP::DEFAULT_NAME
    field :external_url, as: :text
    field :open_date, as: :date
    field :close_date, as: :date
    field :event, as: :belongs_to
  end
end
