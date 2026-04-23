require_relative "boot"

require "rails/all"

# frozen:ssg
if ARGV.first == "build"
  require "parklife-rails/activestorage"
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MunichRubyshiftOrg
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets generators tasks templates])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # frozen:md
    # config.assets.paths << Rails.root.join("content")
    config.action_dispatch.rescue_responses["Decant::FileNotFound"] = :not_found

    # frozen:db
    config.generators do |g|
      g.orm :active_record, primary_key_type: :string
      g.helper nil
    end
    config.active_storage.draw_routes = true

    # frozen:ui
    config.i18n.available_locales = [ :en, :de ]
    config.view_component.parent_class = "ApplicationComponent"
    config.view_component.generate.preview = true
    config.view_component.generate.preview_path = "test/components"
    config.view_component.generate.locale = true
    config.view_component.previews.default_layout = "component_preview"
    config.asset_path = "/assets"
    # Use propshaft in development and precompiled_assets in production. Very brittle.
    config.assets.paths << Rails.root.join("app/assets") if Rails.env.development?
  end
end
