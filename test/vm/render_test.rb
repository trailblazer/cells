require 'test_helper'

class SongCell < Cell::ViewModel
  self.view_paths = ["test/vm/fixtures"]

  def show
    render
  end

  def ivar
    @title = "Carnage"
    render
  end

  def unknown
    render
  end

  def string
    "Right"
  end

  # TODO: just pass hash.
  def with_locals
    render locals: {length: 280, title: "Shot Across The Bow"}
  end

  def with_erb
    render
  end

  def with_view_name
    render :show
  end

private
  def title
    "Papertiger"
  end
end

class RenderTest < MiniTest::Spec
  # render show.haml calling method.
  it { SongCell.new(nil).show.must_equal "Papertiger\n" }

  # render ivar.haml using instance variable.
  it { SongCell.new(nil).ivar.must_equal "Carnage\n" }

  # render string.
  it { SongCell.new(nil).string.must_equal "Right" }

  # call/render_state

  # throws an exception when not found.
  it do
    exception = assert_raises(Cell::TemplateMissingError) { SongCell.new(nil).unknown }
    exception.message.must_equal "Template missing: view: `unknown[.haml|.erb]` prefixes: [\"song\"] view_paths:[\"test/vm/fixtures\"]"
  end

  # allows locals
  it { SongCell.new(nil).with_locals.must_equal "Shot Across The Bow\n280\n" }

  # render :show is a shortcut.
  it { SongCell.new(nil).with_view_name.must_equal "Papertiger\n" }

  # renders ERB.
  it { SongCell.new(nil).with_erb.must_equal "ERB:\n<span>\n  Papertiger\n</span>\n" }

  # let first engine win over last engine.
end

# test inheritance

# test view: :bla and :bla
# with layout and locals.
# with layout and :text


# Tilt::ErubisTemplate.class_eval do
#     def precompiled_preamble(locals)
#       #{}"@output_buffer = output_buffer || ActionView::OutputBuffer.new;"
#       #raise
#       [super, "#{@outvar} = _buf = ''"].join("\n")
#     end
# end


class ::Erubis::Eruby
  BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

  def add_expr_literal(src, code)
    if code =~ BLOCK_EXPR
      src << '_buf<< ' << code
    else
      src << '_buf<< (' << code << ');'
    end
  end
end