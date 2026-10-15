ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# System tests drive a browser through a local server.
WebMock.disable_net_connect!(allow_localhost: true)

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

# Answers like github.com, where a profile picture redirects to the image.
module GithubTestHelper
  def stub_github_avatar(username)
    image_url = "https://avatars.githubusercontent.com/#{username}"
    stub_request(:get, "https://github.com/#{username}.png?size=460").to_return(status: 302, headers: { "Location" => image_url })
    stub_request(:get, image_url).to_return(body: file_fixture("image.png").binread, headers: { "Content-Type" => "image/png" })
  end

  def stub_unknown_github_user(username)
    stub_request(:get, "https://github.com/#{username}.png?size=460").to_return(status: 404, body: "Not Found")
  end
end
