# Active Storage keeps its files in content/storage, a git submodule that a
# plain clone leaves empty (see the README). Changing a file without it would
# record the change in content/data, but leave git unaware of the file itself.
module StorageCheckout
  class NotCheckedOut < StandardError; end

  # A checked-out submodule holds a `.git` file, one that was never checked out
  # is an empty directory.
  def self.checked_out?
    root.join(".git").exist?
  end

  def self.ensure_checked_out!
    raise NotCheckedOut, not_checked_out_message unless checked_out?
  end

  def self.not_checked_out_message
    "#{relative_root} isn't checked out, run `git submodule update --init #{relative_root}` first"
  end

  def self.relative_root
    root.relative_path_from(Rails.root)
  end

  # The services in config/storage.yml share the submodule as their root.
  def self.root
    Pathname(ActiveStorage::Blob.service.root)
  end
  private_class_method :root
end
