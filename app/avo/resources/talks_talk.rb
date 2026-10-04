class Avo::Resources::TalksTalk < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::Talk
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  # Only "q_and_a" doesn't humanize well.
  KIND_OPTIONS = ::Talks::Talk::KINDS.index_by { |kind| kind == "q_and_a" ? "Q&A" : kind.humanize }.freeze

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :title, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :event, as: :belongs_to, **sortable(:by_start_date, on: :event)
    field :description, as: :textarea
    field :slides_url, as: :text, sortable: true
    field :kind, as: :select, sortable: true, options: KIND_OPTIONS, default: "talk"
    field :announced_at, as: :date_time, sortable: true
    field :language_code, as: :select, name: "Language", sortable: true, options: ::Language::NAMES.invert, default: "en"
  end
end
