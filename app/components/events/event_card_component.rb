class Events::EventCardComponent < ApplicationComponent
  delegate :event_title, :event_date, :event_time_range, :event_upcoming?, to: :helpers

  attr_reader :event

  def initialize(event, featured: false)
    @event = event
    @featured = featured
  end

  def featured?
    @featured
  end

  def talks
    @talks ||= event.talks.includes(:speakers).to_a
  end

  def css_classes
    class_names("events---event-card", "events---event-card-featured origami-paper": featured?, "events---event-card-cancelled": event.cancelled?)
  end
end
