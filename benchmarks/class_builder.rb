require 'bundler/setup'
require 'benchmark/ips'
require "cells"
require 'cell/view_model'

class ACell < Cell::ViewModel
  def show
    ""
  end
end

class ACellWithBuilder < Cell::ViewModel
  include Cell::Builder

  def show
    ""
  end
end

Benchmark.ips do |x|
  x.report("ACell") { ACell.().() }
  x.report("ACellWithBuilder") { ACellWithBuilder.().() }
  x.compare!
end

__END__

Calculating -------------------------------------
               ACell    25.212k i/100ms
    ACellWithBuilder    21.394k i/100ms
-------------------------------------------------
               ACell    378.206k (± 5.2%) i/s -      1.891M
    ACellWithBuilder    293.788k (± 4.7%) i/s -      1.476M

Comparison:
               ACell:   378206.2 i/s
    ACellWithBuilder:   293788.4 i/s - 1.29x slower
