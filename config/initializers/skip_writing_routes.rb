ActiveSupport.on_load(:active_record) do
  require "rails/generators"
  require "rails/generators/erb/scaffold/scaffold_generator"

  Erb::Generators::ScaffoldGenerator.prepend(
    Module.new do
      private

      def available_views
        [ "index", "show" ]
      end
    end
  )
end
