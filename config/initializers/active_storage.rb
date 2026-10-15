# Removing an attachment without the storage submodule would drop its records
# from content/data, but leave its file behind in the submodule.
#
# `purge` and `detach` delete an attachment without callbacks, so only the
# console can still get around this.
ActiveSupport.on_load(:active_storage_attachment) do
  before_destroy { StorageCheckout.ensure_checked_out! }
end
