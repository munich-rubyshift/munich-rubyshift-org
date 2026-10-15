ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Gives each test empty storage of its own, like content/storage in a clone
# that skipped the submodule.
module StorageTestHelper
  extend ActiveSupport::Concern

  included do
    setup do
      @original_storage_root = ActiveStorage::Blob.service.root
      ActiveStorage::Blob.service.root = Dir.mktmpdir
    end

    teardown do
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      ActiveStorage::Blob.service.root = @original_storage_root
    end
  end

  def check_out_storage
    FileUtils.touch(File.join(ActiveStorage::Blob.service.root, ".git"))
  end

  def image_upload(fixture = "image.png", filename: fixture)
    file = file_fixture(fixture)
    Rack::Test::UploadedFile.new(file, Marcel::MimeType.for(file, name: fixture), original_filename: filename)
  end
end

# Points config.x.github_url at a local server that answers like github.com:
# anna's profile picture redirects to test/fixtures/files/image.png, anyone
# else's is not found.
module GithubTestHelper
  extend ActiveSupport::Concern

  APP = ->(env) do
    case env["PATH_INFO"]
    when "/anna.png"
      [ 302, { "location" => "http://#{env["HTTP_HOST"]}/avatars/anna" }, [] ]
    when "/avatars/anna"
      [ 200, { "content-type" => "image/png" }, [ Rails.root.join("test/fixtures/files/image.png").binread ] ]
    else
      [ 404, { "content-type" => "text/plain" }, [ "Not Found" ] ]
    end
  end

  def self.url
    @url ||= begin
      require "capybara"
      server = Capybara::Server.new(APP).boot
      "http://#{server.host}:#{server.port}"
    end
  end

  included do
    setup do
      @original_github_url = Rails.configuration.x.github_url
      Rails.configuration.x.github_url = GithubTestHelper.url
    end

    teardown do
      Rails.configuration.x.github_url = @original_github_url
    end
  end
end
