class Api::V1::TalkSerializer < Api::V1::Serializer
  private

  def attributes
    # Stored values: a blank announcement date doesn't fall back to the event's.
    record.attributes.slice("title", "rubyevents_slug", "kind", "language_code", "description", "slides_url",
      "announced_on").merge(
        additional_resources: record.additional_resources.map { |resource| resource.slice(:kind, :name, :title, :url) }
      )
  end

  def relationships
    { speakers: { data: record.speakers.sort_by(&:slug).map { |speaker| identify(speaker) } } }
  end
end
