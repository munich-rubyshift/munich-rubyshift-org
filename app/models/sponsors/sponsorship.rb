class Sponsors::Sponsorship < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :entities_organization
  belongs_to :sponsors_sponsor_tier
end
