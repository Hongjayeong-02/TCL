set port_name "data"

puts "Original : $port_name"

regsub {data} $port_name {data_bus} new_name

puts "Modified : $new_name"
