# Active Storage keeps its files in content/storage, a git submodule that a
# plain clone leaves empty (see the README). Changing a file without it would
# record the change in content/data, but leave git unaware of the file itself.
module StorageCheckout
  extend self

  class NotCheckedOut < StandardError; end
  class FileMissing < StandardError; end

  # A checked-out submodule holds a `.git` file, one that was never checked out
  # is an empty directory.
  def checked_out?
    root.join(".git").exist?
  end

  def ensure_checked_out!
    raise NotCheckedOut, not_checked_out_message unless checked_out?
  end

  def not_checked_out_message
    "#{relative_root} isn't checked out, run `git submodule update --init #{relative_root}` first"
  end

  def file_missing_message(filename)
    "#{filename} is missing from #{relative_root}, run `git submodule update` to check out the files this commit expects"
  end

  private

  def relative_root
    root.relative_path_from(Rails.root)
  end

  # The services in config/storage.yml share the submodule as their root.
  def root
    Pathname(ActiveStorage::Blob.service.root)
  end
end
