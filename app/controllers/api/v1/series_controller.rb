class Api::V1::SeriesController < Api::V1::ApplicationController
  def index
    render_list Events::Series.order(:slug).map { |series| Api::V1::SeriesSerializer.new(series).resource }
  end
end
