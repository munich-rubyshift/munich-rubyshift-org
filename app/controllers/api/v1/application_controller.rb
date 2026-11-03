class Api::V1::ApplicationController < ApplicationController
  private

  def render_document(data, included: nil)
    render json: { jsonapi: { version: "1.1" }, data:, included: }.compact
  end
end
