class Avo::Resources::TalksTalk < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::Talk
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :title, as: :text
    field :rubyevents_slug, as: :text
    field :event, as: :belongs_to
    field :description, as: :textarea
    field :raw_title, as: :text
    field :original_title, as: :text
    field :slides_url, as: :text
    field :external_id, as: :text
    field :kind, as: :text
    field :status, as: :text
    field :date, as: :date
    field :time, as: :date_time
    field :published_at, as: :date_time
    field :announced_at, as: :date_time
    field :removed, as: :text
    field :location, as: :text
    field :video_provider, as: :text
    field :video_id, as: :text
    field :external_player, as: :boolean
    field :external_player_url, as: :text
    field :track, as: :text
    field :language, as: :text
  end
end
