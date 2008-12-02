# Copyright (c) 2007-2008 Nick Sutterer <apotonick@gmail.com>
# Copyright (c) 2007-2008 Solide ICT by Peter Bex <peter.bex@solide-ict.nl> 
# and Bob Leers <bleers@fastmail.fm>
# Some portions and ideas stolen ruthlessly from Ezra Zygmuntowicz <ezmobius@gmail.com>
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'cell'
require 'cell_extensions'
require 'action_view_extensions'

ActionController::Base.class_eval do
  include Cell::ControllerMethods
end

# add APP_CELLS_PATH to $LOAD_PATH:
ActiveSupport::Dependencies.load_paths << RAILS_ROOT+"/app/cells"

# add APP_CELLS_PATH to view_paths:
Cell::Base.view_paths=([RAILS_ROOT+"/app/cells"])


# add engine-cells view/code paths, once at server start.
if Cell.engines_available?
  config.after_initialize do
    Engines.plugins.each do |plugin|
      engine_cells_dir = File.join([plugin.directory, "app/cells"])
      
      # add view paths:
      if File.exists?(engine_cells_dir)
        Cell::Base.view_paths << engine_cells_dir 
        # add code path:
        ActiveSupport::Dependencies.load_paths << engine_cells_dir
      end
    end
  end
  
end

# calls Dispatcher#to_prepare, so the views get reloaded after each request 
# in development mode.
config.to_prepare do
  Cell::Base.view_paths.reload!
end

