class Avo::Resources::EventsEvent < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Event
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :title, as: :text
    field :rubyevents_slug, as: :text
    field :series, as: :belongs_to
    field :venue, as: :belongs_to, required: -> { record&.venue_required? }, help: "Required unless the event is online or cancelled, and forbidden for online events."
    field :description, as: :textarea
    field :kind, as: :select, options: ::Events::Event::KINDS.index_by(&:humanize), include_blank: true
    field :attendance_mode, as: :select, options: ::Events::Event::ATTENDANCE_MODES.index_by(&:humanize)
    field :status, as: :select, options: ::Events::Event::STATUSES.index_by(&:humanize), include_blank: true
    field :last_edition, as: :boolean
    field :start_date, as: :date
    field :start_time, as: :time
    field :end_date, as: :date
    field :end_time, as: :time
    field :published_at, as: :date_time
    field :announced_on, as: :date
    field :date_precision, as: :select, options: ::Events::Event::DATE_PRECISIONS.index_by(&:humanize), include_blank: true
    field :channel_id, as: :text
    field :playlist, as: :text
    field :website, as: :text
    field :twitter, as: :text
    field :mastodon, as: :text
    field :github, as: :text
    field :meetup, as: :text
    field :luma, as: :text
    field :youtube, as: :text
    field :tickets_url, as: :text
    field :banner_background, as: :text
    field :featured_background, as: :text
    field :featured_color, as: :text
  end
end
