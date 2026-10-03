puts "========================================"
puts " Tcl Control Flow : if / switch"
puts "========================================"

set slack -0.15

if {$slack >= 0} {
    puts "TIMING PASS"
} else {
    puts "TIMING VIOLATION"
}

set corner "slow"

switch $corner {
    "fast" {
        puts "FAST CORNER"
    }

    "slow" {
        puts "SLOW CORNER"
    }

    default {
        puts "UNKNOWN CORNER"
    }
}
