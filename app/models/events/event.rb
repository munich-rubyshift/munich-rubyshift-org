class Events::Event < ApplicationRecord
  include FriendlyId
  friendly_id :title

  belongs_to :venue, class_name: "Venues::Venue", foreign_key: :venues_venue_id, inverse_of: :events
end
