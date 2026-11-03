# Turns a record into a JSON:API resource object.
class Api::V1::Serializer
  TYPES = {
    "Entities::Person" => "people",
    "Entities::Organization" => "organizations",
    "Locations::City" => "cities",
    "Events::Series" => "series",
    "Events::Event" => "events",
    "Venues::Venue" => "venues",
    "Locations::Address" => "addresses",
    "Talks::Talk" => "talks",
    "Sponsors::SponsorTier" => "sponsor_tiers",
    "Events::CFP" => "cfps"
  }.freeze

  # Our JSON:API ids are slugs: the UUIDs stay ours.
  def self.identifier(record)
    { type: TYPES.fetch(record.class.name), id: record.slug } if record
  end

  attr_reader :record

  def initialize(record)
    @record = record
  end

  def resource
    { **identifier, attributes:, relationships: }.compact
  end

  def identifier
    self.class.identifier(record)
  end

  private

  def relationships
  end

  def identify(record)
    self.class.identifier(record)
  end

  def coordinates(coordinates)
    { latitude: coordinates.latitude.to_f, longitude: coordinates.longitude.to_f }
  end

  # Like StoredImageComponent, generating the URL is what copies the file into a Parklife build.
  def stored_image_path(attachment)
    return unless attachment.attached? && StorageCheckout.file_present?(attachment)

    Rails.application.routes.url_helpers.polymorphic_url(attachment, only_path: true)
  end
end
