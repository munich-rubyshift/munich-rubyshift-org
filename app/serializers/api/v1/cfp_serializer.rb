class Api::V1::CFPSerializer < Api::V1::Serializer
  private

  def attributes
    # Stored values: a blank close date doesn't fall back to the day before the event.
    record.attributes.slice("name", "open_date", "close_date", "external_url")
  end
end
