class Venues::Venue < ApplicationRecord
  include FriendlyId
  friendly_id :name

  has_many :events, class_name: "::Events::Event", foreign_key: :venues_venue_id, inverse_of: :venue

  def to_s
    name
  end
end
