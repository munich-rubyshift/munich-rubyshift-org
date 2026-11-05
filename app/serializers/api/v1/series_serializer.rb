class Api::V1::SeriesSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :kind, :frequency, :language_code, :default_country_code, :time_zone, :ended,
      :description, :website, :twitter_username, :mastodon, :bluesky_handle, :github, :meetup, :luma, :guild, :linkedin,
      :discord, :facebook, :banner_background, :featured_background, :featured_color)
  end

  def relationships
    { events: { data: record.events.order(start_date: :desc, slug: :asc).map { |event| identify(event) } } }
  end
end
