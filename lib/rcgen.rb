#!/usr/bin/env ruby

# Data Definition Module
module RcGen

  csv_file='data/data_def.csv'
  require 'faster_csv'
  
  @@data_def = Array.new
  FasterCSV.foreach(csv_file, :headers => true) do |csv_obj|
    csv_obj['column'] = csv_obj['column'] unless csv_obj['column'].nil?
    csv_obj['type'] = csv_obj['type'] unless csv_obj['type'].nil?
    @@data_def.push csv_obj
  end
  
  # Filter out anything that is not fully defined
  @@data_def = @@data_def.find_all { |row| 
    ! row['type'].nil? && 
    ! row['column'].nil? 
  }
  
  # Return something like VARCHAR(15), or NUMERIC(11,2)
  def db_type(row)
    len = row['length']
    scale = row['scale']
    type = row['type']
    return nil if type.nil?
    return type if len.nil?
    return type + "(#{len})" if scale.nil?
    return type + "(#{len},#{scale})"
  end
  
  def format_row(format_type, row)
    column = row['column']
    case format_type
    when :col
      # Ex: PRI_PAY
      column
    when :col_type
      # Ex: ACQ_UNIT_COST NUMERIC(11, 4)
      column + " " + db_type(row)
    when :col_def
      # Ex: SEQ CHAR(4) NOT NULL
      nn = row['not null']
      default = row['default']
      segments = Array.new
      segments.push(column + " " + db_type(row))
      segments.push("DEFAULT '#{default}'") if ! default.nil?
      segments.push("NOT NULL") if nn
      segments.join ' '
    end
  end
  
  def formula(conditions)
  
    return "true" if conditions.empty?
  
    conditionArray=conditions.split ','
    formulaArray=Array.new
  
    conditionArray.each do |condition|
      # Ex: my_column == rx
      column, condition, value = condition.split ' '
  
      if condition.nil? && value.nil?
        # short-hand: my_column.rx
        column, value = column.split('.')
        if value.nil?
          condition='!='
        else
          condition='=='
        end
      end
      if value == "''" || value == '""' || value.nil? || value.empty?
         value = "nil"
      else 
         value = "'#{value}'"
      end
      
      formulaArray.push "row['#{column}'] #{condition} #{value}"
    end
    return formulaArray.join ' && '
  end
  
  def rows(condition="")
    f=formula condition
    @@data_def.find_all {|row| eval(f) }
  end
  
  def columns(column="column", condition="")
    a=rows condition
    a.collect {|row| row[column] }
  end
  
  def distinct(column="table", condition="")
    a=Array.new
    rows(condition).each do |row| 
       a.push row[column] unless row[column].nil? || a.index(row[column])
    end
    return a
  end
  
  # Comma Select
  
  def col(condition="", delimiter=", ")
    a=rows(condition).collect {|row| format_row(:col, row) }
    if delimiter.nil?
      a
    else
      a.join delimiter
    end
  end
  
  def colType(condition="", delimiter=", ")
    a=rows(condition).collect {|row| format_row(:col_type, row) }
    if delimiter.nil?
      a
    else
      a.join delimiter
    end
  end
  
  def colDef(condition="", delimiter=",\n")
    a=rows(condition).collect {|row| format_row(:col_def, row) }
    if delimiter.nil?
      a
    else
      a.join delimiter
    end
  end
  
end #module
