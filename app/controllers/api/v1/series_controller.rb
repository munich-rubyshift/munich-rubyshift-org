class Api::V1::SeriesController < Api::V1::ApplicationController
  def index
    render_list Events::Series.order(:slug), serializer: Api::V1::SeriesSerializer
  end
end
