class Api::V1::EventsController < Api::V1::ApplicationController
  def show
    serializer = Api::V1::EventSerializer.new(Events::Event.find(params.expect(:id)))
    render_document serializer.resource, included: serializer.included
  end
end
