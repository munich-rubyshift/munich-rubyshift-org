class Api::V1::Serializer
  include ActiveModel::Validations

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
    "Sponsors::Sponsorship" => "sponsorships",
    "Events::Involvement" => "involvements",
    "Events::CFP" => "cfps"
  }.freeze

  class_attribute :attribute_readers, instance_accessor: false, default: {}

  # Without a block, the value comes from the record's reader, so the model's fallbacks apply.
  def self.attribute(name, &reader)
    self.attribute_readers = attribute_readers.merge(name => reader)
  end

  attr_reader :record

  def initialize(record, rubyevents:)
    @record = record
    @rubyevents = rubyevents
  end

  def resource
    { **identifier, attributes: exported_attributes, relationships: }.compact
  end

  def identifier
    identify(record)
  end

  # Runs the validations `on: :rubyevents`, which check the exported values against rules of RubyEvents.
  def valid_for_rubyevents?
    valid?(:rubyevents)
  end

  private

  attr_reader :rubyevents

  def attributes
    self.class.attribute_readers.to_h { |name, reader| [ name, reader ? instance_exec(&reader) : record.public_send(name) ] }
  end

  def exported_attributes
    with_rubyevents_data(record, attributes)
  end

  def relationships
  end

  def identify(record)
    { type: TYPES.fetch(record.class.base_class.name), id: record.id } if record
  end

  def with_rubyevents_data(record, values)
    rubyevents ? values.stringify_keys.merge(record.rubyevents_data.to_h) : values
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
