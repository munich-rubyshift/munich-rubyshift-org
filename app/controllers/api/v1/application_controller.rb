class Api::V1::ApplicationController < ApplicationController
  private

  # Whether this is /api/rubyevents-v1, which routes to these controllers too.
  def rubyevents?
    request.path_parameters.fetch(:rubyevents, false)
  end

  # This static site publishes every list as a single page, but clients should follow links.next as with any paginated API.
  def render_list(records, serializer:)
    resources = records.map { |record| serializer.new(record, rubyevents: rubyevents?).resource }
    render_document(resources, links: { next: nil })
  end

  def render_document(data, included: nil, links: nil)
    render json: { jsonapi: { version: "1.1" }, links:, data:, included: }.compact
  end
end
