class Avo::Resources::TalksTalk < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::Talk
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :title, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :event, as: :belongs_to, **belongs_to_field_options(:event)
    field :description, as: :textarea
    field :raw_title, as: :text, sortable: true
    field :original_title, as: :text, sortable: true
    field :slides_url, as: :text, sortable: true
    field :external_id, as: :text, sortable: true
    field :kind, as: :text, sortable: true
    field :status, as: :text, sortable: true
    field :date, as: :date, sortable: true
    field :time, as: :date_time, sortable: true
    field :published_at, as: :date_time, sortable: true
    field :announced_at, as: :date_time, sortable: true
    field :removed, as: :text, sortable: true
    field :location, as: :text, sortable: true
    field :video_provider, as: :text, sortable: true
    field :video_id, as: :text, sortable: true
    field :external_player, as: :boolean, sortable: true
    field :external_player_url, as: :text, sortable: true
    field :track, as: :text, sortable: true
    field :language, as: :text, sortable: true
  end
end
