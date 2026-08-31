# Slugs are editable in Avo, so they need the same care as any other form input.
# FriendlyId only generates a slug when the column is nil, and it stores a
# hand-written one verbatim, so normalize both cases ourselves.
module Sluggable
  extend ActiveSupport::Concern

  included do
    include FriendlyId

    # A form sends "" for a cleared slug. Turn that back into nil so FriendlyId
    # regenerates it, and keep anything typed by hand URL-safe.
    normalizes :slug, with: ->(slug) { slug.presence&.parameterize }

    # `reserved` validates the :friendly_id pseudo-attribute, which no form field
    # maps to. Move the error onto :slug so Avo can highlight the input.
    after_validation :move_friendly_id_errors_to_slug
  end

  private

  def move_friendly_id_errors_to_slug
    errors.delete(:friendly_id)&.each { |message| errors.add(:slug, message) }
  end
end
