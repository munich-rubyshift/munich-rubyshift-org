require "generators/avo/controller_generator"

module Generators
  module Avo
    class ControllerGenerator
      def create
        return if override_controller?

        template "resource/controller.tt", "app/avo/controllers/#{controller_name}.rb"
      end
    end
  end
end
