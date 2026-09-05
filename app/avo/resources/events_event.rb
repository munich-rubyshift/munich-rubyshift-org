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
    field :rubyevents_slug, as: :text

    field :kind, as: :select, options: ::Events::Event::KINDS.index_by(&:humanize), include_blank: true, default: "meetup"

    grouped "When?" do
      row do
        field :start_date, as: :date
        field :start_time, as: :time
      end
      row do
        field :end_date, as: :date
        field :end_time, as: :time
      end
      field :date_precision, as: :select, options: ::Events::Event::DATE_PRECISIONS.index_by(&:humanize), include_blank: true, default: "day"
      field :status, as: :select, options: ::Events::Event::STATUSES.index_by(&:humanize), include_blank: true, default: "scheduled"
    end

    grouped "Where?" do
      field :attendance_mode, as: :select, options: ::Events::Event::ATTENDANCE_MODES.index_by(&:humanize)
      field :venue, as: :belongs_to, required: -> { record&.venue_required? }, help: "Required unless the event is online or cancelled, and forbidden for online events."
      field :tickets_url, as: :text
    end

    grouped "What?" do
      field :title, as: :text
      field :description, as: :textarea
    end

    field :channel_id, as: :text
    field :playlist, as: :text
    field :youtube, as: :text

    field :series, as: :belongs_to, default: -> { ::Events::Series.first }
    field :website, as: :text, **series_default_options(:website)
    field :twitter, as: :text, **series_default_options(:twitter)
    field :mastodon, as: :text, **series_default_options(:mastodon)
    field :github, as: :text, **series_default_options(:github)
    field :meetup, as: :text, **series_default_options(:meetup)
    field :luma, as: :text, **series_default_options(:luma)

    field :banner_background, as: :text
    field :featured_background, as: :text
    field :featured_color, as: :text

    field :published_at, as: :date_time
    field :announced_on, as: :date
    field :last_edition, as: :boolean
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
