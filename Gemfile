source "https://rubygems.org"

gem "benchmark-ips"
gem "minitest-line"

gemspec

case ENV["GEMS_SOURCE"]
  when "local"
    gem "cells-erb", path: "../cells-erb"
  # gem "erbse", path: "../erbse"
  when "github"
    gem "cells-erb", github: "trailblazer/cells-erb"
end
