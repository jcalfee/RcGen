#!/usr/bin/env ruby

module RCsv

require File.dirname(__FILE__) + '/faster_csv.rb'

def process template_file, input_csv

  is_erb=template_file.match ".erb"
  if is_erb
    require 'erb' 
    template=ERB.new IO.read template_file
  else
    template=IO.read template_file
  end

  FasterCSV.foreach(input_csv, :headers => true) do |$row|
    if is_erb
      puts template.result
    else
      puts eval template
    end
end

end

def escape value
  value.sub "'", "''"
end

def empty? value
  value.nil? || value.strip.empty?
end

def empty_value
  'null'
end

def quote_char
  "'"
end

def format value
  return empty_value if empty? value
  quote_char + escape(value) + quote_char
end

def value column
  format $row[column]
end

def values column_array
  column_array.collect do|column| 
    format $row[column]
  end
end

def data_row
  $row
end


end #module
