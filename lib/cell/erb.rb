require 'erubis/engine/eruby'

# The original ERB implementation in Ruby doesn't support blocks like
#   <%= form_for do %>
# which is fixed with this monkey-patch.
#
# TODO: don't monkey-patch, use this in cells/tilt, only!
module Erubis
  module RubyGenerator
    def init_generator(properties={})
      super
      @escapefunc ||= "Erubis::XmlHelper.escape_xml"
      @bufvar       = properties[:bufvar] || "_buf"
      @in_block     = 0
      @block_ignore = 0
    end

    def escaped_expr(code)
      return "#{@escapefunc} #{code}"
    end

    def add_stmt(src, code)
      if block_start? code
        block_ignore
      elsif block_end? code
        src << @bufvar << ?;
        block_end
      end

      src << "#{code};"
    end

    def add_expr_literal(src, code)
      if block_start? code
        src << "#@bufvar << #{code};"
        block_start
        src << "#@bufvar = '';"
      else
        src << "#{@bufvar} << (#{code}).to_s;"
      end
    end

    private
    def block_start? code
      res = code =~ /\b(do|\{)(\s*\|[^|]*\|)?\s*\Z/
    end
    def block_start
      @in_block += 1
      @bufvar << '_tmp'
    end

    def block_ignore
      @block_ignore += 1
    end

    def block_end? code
      res = @in_block != 0 && code =~ /\bend\b|}/
      if res && @block_ignore != 0
        @block_ignore -= 1
        return false
      end

      res
    end
    def block_end
      @in_block -= 1
      @bufvar.sub! /_tmp\Z/, ''
    end
  end
end
