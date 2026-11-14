class Api::V1::TalkSerializer < Api::V1::Serializer
  attribute :slug
  attribute :title
  attribute :kind
  attribute :language_code
  attribute :description
  attribute :slides_url
  attribute :announced_on

  attribute :additional_resources do
    record.additional_resources.map { |resource| with_rubyevents_data(resource, resource.slice(:kind, :name, :title, :url)) }
  end

  private

  def relationships
    { speakers: { data: record.speakers.sort_by(&:slug).map { |speaker| identify(speaker) } } }
  end
end
