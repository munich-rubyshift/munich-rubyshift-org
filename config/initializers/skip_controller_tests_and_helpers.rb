ActiveSupport.on_load(:active_record) do
  require "rails/generators"
  require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

  Rails::Generators::ScaffoldControllerGenerator.class_eval do
    remove_hook_for :test_framework
    remove_hook_for :helper
  end
end
