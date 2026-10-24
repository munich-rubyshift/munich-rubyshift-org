class Sponsors::SponsorTier < ApplicationRecord
  include StringForeignKeys
  include Sluggable
  include LongFormText
  friendly_id :name

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :sponsor_tiers

  string_fk :events_event_id

  long_form_text :description

  has_many :sponsorships, class_name: "Sponsors::Sponsorship", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsor_tier
  has_many :organizations, class_name: "Entities::Organization", through: :sponsorships

  def to_s
    name
  end
end
