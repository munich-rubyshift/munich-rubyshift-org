class Api::V1::SeriesController < Api::V1::ApplicationController
  def index
    render_document Events::Series.order(:slug).map { |series| Api::V1::SeriesSerializer.new(series).resource }
  end
end
