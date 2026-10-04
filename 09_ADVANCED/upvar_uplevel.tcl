# ============================================================
# upvar_uplevel.tcl
#
# Tcl advanced scope handling
#
# 목표
#   - upvar로 caller variable 접근
#   - uplevel로 caller scope에서 command 실행
#   - EDA automation에서 shared state와 command wrapper 이해
# ============================================================


puts "========================================"
puts " Tcl upvar / uplevel"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# upvar basic
# ------------------------------------------------------------

proc increment_counter {var_name} {

    upvar 1 $var_name counter

    incr counter
}


puts ""
puts "Stage 1 : upvar"
puts "----------------------------------------"

set warning_count 0

increment_counter warning_count
increment_counter warning_count
increment_counter warning_count

puts "warning_count = $warning_count"


# ------------------------------------------------------------
# Stage 2
# upvar for EDA-style result accumulation
# ------------------------------------------------------------

proc add_area {total_var area} {

    upvar 1 $total_var total

    set total [expr {$total + $area}]
}


puts ""
puts "Stage 2 : accumulate area"
puts "----------------------------------------"

set total_area 0.0

add_area total_area 2.5
add_area total_area 2.8
add_area total_area 5.2

puts [format "total_area = %.2f" $total_area]


# ------------------------------------------------------------
# Stage 3
# uplevel basic
# ------------------------------------------------------------

proc run_in_caller {command} {

    puts "Executing in caller scope:"
    puts "  $command"

    return [uplevel 1 $command]
}


puts ""
puts "Stage 3 : uplevel"
puts "----------------------------------------"

set design_name uart_apb

run_in_caller {
    puts "design_name = $design_name"
}


# ------------------------------------------------------------
# Stage 4
# command wrapper
# ------------------------------------------------------------

proc run_checked {command} {

    puts ""
    puts "RUN : $command"

    set result [uplevel 1 $command]

    puts "DONE"

    return $result
}


puts ""
puts "Stage 4 : command wrapper"
puts "----------------------------------------"

set rtl_list {
    uart_tx.v
    uart_rx.v
    uart_core.v
}

set count [run_checked {
    llength $rtl_list
}]

puts "RTL file count = $count"
