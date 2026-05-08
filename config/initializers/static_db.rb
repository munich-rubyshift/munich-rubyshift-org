StaticDb.configure do |config|
  config.static_db_path = Rails.root.join("content", "data")

  # Selectively activate loading and dumping. Active by default. Set to any other value to disable.
  config.load = ENV["STATIC_DB"].in? [ "load", nil, "on", "true", "1" ]
  config.dump = ENV["STATIC_DB"].in? [ "dump", nil, "on", "true", "1" ]
end
