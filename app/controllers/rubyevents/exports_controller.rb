class Rubyevents::ExportsController < ApplicationController
  # Parklife bakes this response into the static build, so the same link works
  # against a running server in development and against a file in production.
  # Only the strict export is published: a build cannot carry a query string,
  # and placeholder data has no business on a public URL.
  def show
    export = Rubyevents::Export.new(mode: mode).validate!

    send_data export.zip, filename: "rubyevents-export.zip", type: "application/zip"
  end

  private

  def mode
    ActiveModel::Type::Boolean.new.cast(params[:lenient]) ? :lenient : :strict
  end
end
