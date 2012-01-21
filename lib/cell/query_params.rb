require "cgi"
module Cell

  #
  # Original source: https://github.com/simen/queryparams/blob/master/lib/queryparams.rb
  #

  module QueryParams

    def self.encode(value, key = nil)
      case value
      when Hash  then value.sort.map { |arr| encode(arr[1], append_key(key,arr[0])) }.join('&')
      when Array then value.map { |v| encode(v, "#{key}[]") }.join('&')
      when nil   then  ''
      when String then value
      else
        "#{key}=#{CGI.escape(value.to_s)}"
      end
    end

    private

    def self.append_key(root_key, key)
      root_key.nil? ? key : "#{root_key}[#{key.to_s}]"
    end
  end
end
