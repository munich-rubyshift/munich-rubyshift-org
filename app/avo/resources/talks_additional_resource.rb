class Avo::Resources::TalksAdditionalResource < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::AdditionalResource
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :kind, as: :select, sortable: true, options: ::Talks::AdditionalResource::KINDS.index_by(&:humanize), include_blank: true
    field :name, as: :text, sortable: true
    field :url, as: :text, sortable: true
    field :title, as: :text, sortable: true
    field :talk, as: :belongs_to, **belongs_to_field_options(:talk)
  end
end
