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

    grouped "When?" do
      # A date and its time are one moment split across two columns, so the time
      # follows the date's direction rather than settling ties in a fixed one:
      # newest first should open a day with its latest event, not its earliest.
      # Sorting on the time alone would order breakfasts against evening talks.
      row do
        field :start_date, as: :date, sortable: -> { query.order(start_date: direction, start_time: direction) }
        field :start_time, as: :time
      end
      row do
        field :end_date, as: :date, sortable: -> { query.order(end_date: direction, end_time: direction) }
        field :end_time, as: :time
      end
      field :date_precision, as: :select, sortable: true, options: ::Events::Event::DATE_PRECISIONS.index_by(&:humanize), include_blank: true, default: "day"
      field :status, as: :select, sortable: true, options: ::Events::Event::STATUSES.index_by(&:humanize), include_blank: true, default: "scheduled"
    end

    grouped "Where?" do
      field :attendance_mode, as: :select, sortable: true, options: ::Events::Event::ATTENDANCE_MODES.index_by(&:humanize)
      field :venue, as: :belongs_to, **belongs_to_field_options(:venue), required: -> { record&.venue_required? }, help: "Required unless the event is online or cancelled, and forbidden for online events."
      field :tickets_url, as: :text, sortable: true
    end

    grouped "What?" do
      field :title, as: :text, sortable: true
      field :description, as: :textarea
    end

    field :channel_id, as: :text, sortable: true
    field :playlist, as: :text, sortable: true
    field :youtube, as: :text, sortable: true

    field :series, as: :belongs_to, **belongs_to_field_options(:series), default: -> { ::Events::Series.first }
    field :website, as: :text, sortable: true, **series_default_options(:website)
    field :twitter, as: :text, sortable: true, **series_default_options(:twitter)
    field :mastodon, as: :text, sortable: true, **series_default_options(:mastodon)
    field :github, as: :text, sortable: true, **series_default_options(:github)
    field :meetup, as: :text, sortable: true, **series_default_options(:meetup)
    field :luma, as: :text, sortable: true, **series_default_options(:luma)

    field :banner_background, as: :text, sortable: true
    field :featured_background, as: :text, sortable: true
    field :featured_color, as: :text, sortable: true

    field :published_at, as: :date_time, sortable: true
    field :announced_on, as: :date, sortable: true
    field :last_edition, as: :boolean, sortable: true
  end

  private

  # Avo builds the index table from the root and main-panel fields only, so a
  # named panel would drop its columns from the table. Group the record views
  # and leave the index flat.
  def grouped(name, &block)
    view.index? ? yield : panel(name, &block)
  end

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
