module Events
  # An event may override some of its series' values.
  module SeriesDefaults
    extend ActiveSupport::Concern

    # "kind" is deliberately excluded, because the set of allowed values differs,
    # and "description" because an event describes its own edition.
    INHERITED = %i[website twitter mastodon github meetup luma].freeze

    INHERITED.each do |attribute|
      define_method(attribute) do
        super().presence || series&.public_send(attribute).presence
      end
    end
  end
end
