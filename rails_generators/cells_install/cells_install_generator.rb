class CellsInstallGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory File.join('config', 'initializers')
      m.directory File.join('lib', 'tasks')
      m.template  'initializer.rb', File.join('config', 'initializers', 'cells.rb')
      m.template  'tasks.rake', File.join('lib', 'tasks', 'cells.rake')
    end
  end
end
