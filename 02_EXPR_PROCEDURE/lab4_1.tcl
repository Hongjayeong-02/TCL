proc to_bits {a} {

    if {$a < 0 || $a > 15} {
        puts "WARNING : input must be between 0 and 15"
        return
    }

    set b0 [expr {$a & 1}]
    set b1 [expr {($a >> 1) & 1}]
    set b2 [expr {($a >> 2) & 1}]
    set b3 [expr {($a >> 3) & 1}]

    set b "$b3$b2$b1$b0"

    return $b
}

puts "14 -> [to_bits 14]"
puts "9  -> [to_bits 9]"
puts "18 -> [to_bits 18]"
