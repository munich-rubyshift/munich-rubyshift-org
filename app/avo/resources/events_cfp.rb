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
    field :name, as: :text, sortable: true, default: ::Events::CFP::DEFAULT_NAME
    field :external_url, as: :text, sortable: true
    field :open_date, as: :date, sortable: true
    field :close_date, as: :date, sortable: true
    field :event, as: :belongs_to, **belongs_to_field_options(:event)
  end
end
