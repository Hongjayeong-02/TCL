# ========================================
# Genus Synthesis Flow Example
# ========================================

set DESIGN cmsdk_mcu

set RTL_LIST {
    ./RTL/file1.v
    ./RTL/file2.v
}

puts "========================================"
puts " READ RTL"
puts "========================================"

read_hdl $RTL_LIST

puts "========================================"
puts " ELABORATE"
puts "========================================"

elaborate $DESIGN

puts "========================================"
puts " READ CONSTRAINT"
puts "========================================"

read_sdc ./cons/cmsdk_mcu.sdc

puts "========================================"
puts " SYNTHESIS"
puts "========================================"

syn_generic
syn_map
syn_opt
