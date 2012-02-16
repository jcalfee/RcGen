(rows 'csv').each do|row|
  v=data_row[row['csv']]
  if row['type'] == 'time' and !empty? v
    fv=format(Time.parse(v).strftime "%H:%M:%S")
  else
    fv=format v
  end
  puts """SELECT CAST(#{fv} AS #{db_type row}) FROM RDB$DATABASE; -- csv: #{row['csv']} table.column: #{row['table']}.#{row['column']}"""
end
