# Copyright (c) 2007-2009 Nick Sutterer <apotonick@gmail.com>
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

# load the baby:
Cell::Base
require 'rails_extensions'


ActionController::Base.class_eval do  include Cell::ActionController end
ActionView::Base.class_eval       do  include Cell::ActionView end
Cell::Base.class_eval             do  include Cell::Caching end


ActiveSupport::Dependencies.load_paths << RAILS_ROOT+"/app/cells"
Cell::Base.view_paths=([RAILS_ROOT+"/app/cells"])


# process cells in plugins ("engine-cells").
# thanks to Tore Torell for making me aware of the initializer instance here:
config.after_initialize do
  initializer.loaded_plugins.each do |plugin|
    engine_cells_dir = File.join([plugin.directory, "app/cells"])
    next unless plugin.engine?
    next unless File.exists?(engine_cells_dir)
    
    # propagate the view- and code path of this engine-cell:
    Cell::Base.view_paths << engine_cells_dir 
    ActiveSupport::Dependencies.load_paths << engine_cells_dir
    
    # if a path is in +load_once_path+ it won't be reloaded between requests.
    unless config.reload_plugins?
      ActiveSupport::Dependencies.load_once_paths << engine_cells_dir
    end
  end
end
