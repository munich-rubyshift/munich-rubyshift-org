class Avo::Resources::EventsEvent < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Event
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.default_sort_column = :start_date
  self.default_sort_direction = :desc

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :rubyevents_slug, as: :text, sortable: true

    field :kind, as: :select, sortable: true, options: ::Events::Event::KINDS.index_by(&:humanize), include_blank: true, default: "meetup"

    # Wall clock times in Munich: don't convert them to the browser's time zone.
    grouped "When?" do
      row do
        field :start_date, as: :date, **sortable(:by_start_date)
        field :start_time, as: :time, relative: false
      end
      row do
        field :end_date, as: :date, **sortable(:by_end_date), help: "Leave blank to end on the start date."
        field :end_time, as: :time, relative: false
      end
      field :date_precision, as: :select, sortable: true, options: ::Events::Event::DATE_PRECISIONS.index_by(&:humanize), include_blank: true, default: "day"
      field :status, as: :select, sortable: true, options: ::Events::Event::STATUSES.index_by(&:humanize), include_blank: true, default: "scheduled"
    end

    grouped "Where?" do
      field :attendance_mode, as: :select, sortable: true, options: ::Events::Event::ATTENDANCE_MODES.index_by(&:humanize)
      field :venue, as: :belongs_to, **sortable(:by_to_s, on: :venue), required: -> { record&.venue_required? }, help: "Required unless the event is online or cancelled, and forbidden for online events."
      field :tickets_url, as: :text, sortable: true
    end

    grouped "What?" do
      field :title, as: :text, sortable: true
      field :description, as: :textarea
    end

    field :series, as: :belongs_to, **sortable(:by_to_s, on: :series), default: -> { ::Events::Series.first }
    field :website, as: :text, sortable: true, **series_default_options(:website)
    field :twitter_username, as: :text, sortable: true, **series_default_options(:twitter_username)
    field :mastodon, as: :text, sortable: true, **series_default_options(:mastodon)
    field :github, as: :text, sortable: true, **series_default_options(:github)
    field :meetup, as: :text, sortable: true, **series_default_options(:meetup)
    field :luma, as: :text, sortable: true, **series_default_options(:luma)

    field :published_at, as: :date_time, sortable: true
    field :announced_on, as: :date, sortable: true
    field :last_edition, as: :boolean, sortable: true

    field :cfps, as: :has_many
  end

  def fill_record(...)
    super.tap do |record|
      record.end_date ||= record.start_date
      record.build_default_cfp if record.new_record?
    end
  end

  private

  # An event falls back to its series for blank values (Events::SeriesDefaults),
  # but the form is supposed to show the event's own value. The fallback value
  # is shown as a placeholder.
  def series_default_options(attribute)
    {
      help: "Leave blank to inherit from the series.",
      format_form_using: -> { record.read_attribute(attribute) },
      placeholder: -> { record.series&.public_send(attribute).presence }
    }
  end
end
