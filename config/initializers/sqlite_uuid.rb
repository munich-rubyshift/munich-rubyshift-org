ActiveSupport.on_load(:active_record) do
  require "rails/generators"
  require "rails/generators/active_record/model/model_generator"
  require "rails/generators/active_record/migration/migration_generator"

  ActiveRecord::Generators::ModelGenerator.prepend(
    Module.new do
      private

      def primary_key_type
        ', id: :string, default: -> { "uuid()" }, limit: 36'
      end
    end
  )

  ActiveRecord::Generators::MigrationGenerator.prepend(
    Module.new do
      private

      def primary_key_type
        ', id: :string, default: -> { "uuid()" }, limit: 36'
      end
    end
  )
end
