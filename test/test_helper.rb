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
end
