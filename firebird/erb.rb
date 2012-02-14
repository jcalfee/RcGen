#/usr/bin/env ruby
require 'lib/rcgen.rb'
require 'erb'
require 'firebird/procedure_i.rb'
template = ERB.new STDIN.read
puts template.result

