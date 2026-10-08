class HeroComponent < ApplicationComponent
  DISCORD_URL = "https://discord.gg/EKqHWmCxGZ".freeze
  MEETUP_URL = "https://www.meetup.com/de-DE/munich-rubyshift-ruby-user-group/".freeze

  def next_event
    @next_event ||= Events::Event.where(start_date: Date.current..).by_start_date.first
  end

  def last_event
    @last_event ||= Events::Event.where(start_date: ...Date.current).order(start_date: :desc).first
  end
end
