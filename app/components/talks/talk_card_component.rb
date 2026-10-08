class Talks::TalkCardComponent < ApplicationComponent
  delegate :event_date, to: :helpers

  attr_reader :talk

  def initialize(talk)
    @talk = talk
  end
end
