class Api::V1::SeriesSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :kind
  attribute :language_code
  attribute :default_country_code
  attribute :time_zone
  attribute :description
  attribute :website
  attribute :twitter_username
  attribute :mastodon
  attribute :bluesky_handle
  attribute :github
  attribute :meetup
  attribute :luma
  attribute :guild
  attribute :linkedin
  attribute :discord
  attribute :facebook

  private

  def relationships
    { events: { data: record.events.order(start_date: :desc, slug: :asc).map { |event| identify(event) } } }
  end
end
