# encoding: utf-8

class CellsInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory File.join('config', 'initializers')
      m.template  'initializer.rb', File.join('config', 'initializers', 'cells.rb')
    end
  end

end