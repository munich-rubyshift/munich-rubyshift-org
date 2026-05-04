class Sponsors::SponsorTier < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :sponsor_tiers

  def to_s
    name
  end
end
