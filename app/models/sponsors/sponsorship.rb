class Sponsors::Sponsorship < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :entities_organization, class_name: "Entities::Organization"
  belongs_to :sponsors_sponsor_tier, class_name: "Sponsors::SponsorTier"
end
