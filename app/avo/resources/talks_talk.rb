class Avo::Resources::TalksTalk < Avo::BaseResource
  self.includes = [ :event ]
  # self.attachments = []
  self.model_class = ::Talks::Talk
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.default_sort_column = :event
  self.default_sort_direction = :desc

  # Only "q_and_a" doesn't humanize well.
  KIND_OPTIONS = ::Talks::Talk::KINDS.index_by { |kind| kind == "q_and_a" ? "Q&A" : kind.humanize }.freeze

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :rubyevents_slug, as: :text, sortable: true
    field :event, as: :belongs_to, **sortable(:by_start_date, on: :event), attach_scope: -> { query.by_start_date.reverse_order }
    field :position, as: :number, sortable: true, help: "Leave blank to add the talk after the event's last one."
    field :kind, as: :select, sortable: true, options: KIND_OPTIONS, default: "talk"
    field :title, as: :text, sortable: true
    field :description, as: :textarea
    field :slides_url, as: :text, sortable: true
    field :language_code, as: :select, name: "Language", sortable: true, options: ::Language::NAMES.invert, default: "en"
    # Like an event's series defaults: the form shows the talk's own date, so
    # saving doesn't copy the event's date onto the talk.
    field :announced_on, as: :date, sortable: true,
      help: "Leave blank if announced together with the event.",
      format_form_using: -> { record.read_attribute(:announced_on) },
      placeholder: -> { record.event&.announced_on&.iso8601 }

    field :speakers, as: :has_many, through: :speaker_talks, scope: -> { query.by_to_s }
    field :additional_resources, as: :has_many
  end
end
