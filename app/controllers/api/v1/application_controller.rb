class Api::V1::ApplicationController < ApplicationController
  private

  # Every list fits on one page, but clients should follow links.next as with any paginated API.
  def render_list(data)
    render_document(data, links: { next: nil })
  end

  def render_document(data, included: nil, links: nil)
    render json: { jsonapi: { version: "1.1" }, links:, data:, included: }.compact
  end
end
