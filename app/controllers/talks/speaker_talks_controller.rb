class Talks::SpeakerTalksController < ApplicationController
  def index
    @talks_speaker_talks = Talks::SpeakerTalk.all
  end

  def show
    @talks_speaker_talk = Talks::SpeakerTalk.find(params.expect(:id))
  end
end
