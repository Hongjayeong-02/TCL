proc find_vector_port {filename} {

    set fid [open $filename r]
    set data [read $fid]
    close $fid

    if {[regexp {([A-Za-z0-9_]+)[ \t]*:[ \t]*(in|out)[ \t]+std_logic_vector} \
        $data match port_name direction]} {

        puts "First Vector Port = $port_name"
        return $port_name
    }

    puts "Vector port not found"
}

find_vector_port "adder.vhdl"
