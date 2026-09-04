FriendlyId.defaults do |config|
  config.use :slugged
  config.use :finders
  config.use :history
  config.use :reserved

  config.reserved_words = %w[
    new edit index
    session login logout users admin
    stylesheets assets javascripts images
    avo pages
  ]
end

require "friendly_id/history"

module FriendlyId
  module History
    private

    # By switching from autoincrement integer IDs to UUIDv4, we made FriendlyId
    # destroy and recreate records unnecessarily. This patch fixes that.
    def history_is_up_to_date?
      history = slugs.where(slug: friendly_id)
      history = history.where(scope: serialized_scope) if friendly_id_config.uses?(:scoped)
      history.exists?
    end
  end
end
