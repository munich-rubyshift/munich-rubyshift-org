require "generators/avo/install_generator"

module Generators
  module Avo
    class InstallGenerator
      def create_initializer_file
        template "initializer/avo.tt", "config/initializers/avo.rb"
      end
    end
  end
end
