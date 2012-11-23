require 'rails/generators'
require 'rails/generators/named_base'

module Cells
  module Generators
    class Base < ::Rails::Generators::NamedBase
      class_option :template_engine
      class_option :test_framework
      class_option :base_cell_class, :type => :string, :default => "Cell::Rails"

      argument :actions, :type => :array, :default => [], :banner => "action action"
      check_class_collision :suffix => "Cell"

    private
      def base_path
        File.join('app/cells', class_path, file_name)
      end
    end
  end
end

# Makes engine namespacing compatible with Rails 3.0
Rails::Generators.instance_eval do
  def namespace; end
end unless Rails::Generators.respond_to? :namespace

Cells::Generators::Base.class_eval do
  def module_namespacing(&block)
    yield if block
  end
end unless Rails::Generators::NamedBase.method_defined? :module_namespacing
