# 03_CONTROL_FLOW

Tcl control-flow practice for conditional execution, repetition, and decision-making.

This module focuses on `if`, `for`, `foreach`, and `while`, which are essential for iterating over RTL files, checking conditions, and controlling EDA automation flows.

---

## Contents

This directory contains examples related to:

- `if`
- `elseif`
- `else`
- `for`
- `foreach`
- `while`
- comparison conditions
- repetitive processing
- conditional PASS / FAIL logic

---

# 1. Running the Scripts

Move to this directory:

```bash
cd ~/TCL/03_CONTROL_FLOW
```

Run a Tcl script with:

```bash
tclsh <script_name>.tcl
```

---

# 2. `if` Statement

Basic conditional execution:

```tcl
set slack 0.12

if {$slack >= 0.0} {
    puts "PASS"
} else {
    puts "FAIL"
}
```

Output:

```text
PASS
```

Concept:

```text
condition
   ↓
 true ──→ execute block A
 false ─→ execute block B
```

This is directly useful for timing, area, and file validation.

---

# 3. `elseif`

Multiple conditions can be evaluated sequentially.

Example:

```tcl
set slack -0.03

if {$slack > 0.0} {
    puts "PASS"
} elseif {$slack == 0.0} {
    puts "ZERO SLACK"
} else {
    puts "VIOLATION"
}
```

Possible result:

```text
VIOLATION
```

EDA-style applications include:

```text
positive slack   → PASS
zero slack       → boundary
negative slack   → FAIL
```

---

# 4. `for` Loop

A `for` loop is useful when iteration count is known.

Example:

```tcl
for {set i 0} {$i < 4} {incr i} {
    puts "Index = $i"
}
```

Output:

```text
Index = 0
Index = 1
Index = 2
Index = 3
```

Hardware-oriented example:

```tcl
for {set bit 0} {$bit < 8} {incr bit} {
    puts "data\[$bit\]"
}
```

---

# 5. `foreach`

`foreach` is particularly important in EDA Tcl because RTL files, library corners, and design objects are commonly represented as lists.

Example:

```tcl
set rtl_list {
    uart_tx.v
    uart_rx.v
    uart_core.v
}

foreach rtl $rtl_list {
    puts "RTL : $rtl"
}
```

Output:

```text
RTL : uart_tx.v
RTL : uart_rx.v
RTL : uart_core.v
```

Concept:

```text
RTL list
   ↓
foreach
   ↓
process one file
   ↓
next file
```

---

# 6. `while`

A `while` loop continues while its condition remains true.

Example:

```tcl
set count 0

while {$count < 3} {
    puts "count = $count"
    incr count
}
```

Output:

```text
count = 0
count = 1
count = 2
```

This can be useful for iterative search or retry-style logic, although EDA scripts often use `foreach` more frequently.

---

# 7. File Validation Example

Control flow becomes useful when checking design files.

Example:

```tcl
set rtl uart_apb.v

if {[file exists $rtl]} {
    puts "PASS : $rtl"
} else {
    puts "FAIL : $rtl"
}
```

This pattern is later used in:

```text
08_EDA_AUTOMATION/uart_filelist_check.tcl
```

---

# 8. Counting PASS / FAIL Results

Example:

```tcl
set pass_count 0
set fail_count 0

foreach file $rtl_list {

    if {[file exists $file]} {
        incr pass_count
    } else {
        incr fail_count
    }
}
```

Summary:

```tcl
puts "PASS : $pass_count"
puts "FAIL : $fail_count"
```

This is a common automation pattern:

```text
input objects
     ↓
foreach
     ↓
if condition
     ↓
PASS / FAIL counter
     ↓
summary
```

---

# EDA Connection

Control-flow commands directly map to practical automation tasks.

```text
Tcl construct        EDA application
------------------------------------------------
if                   constraint / result checks
elseif               multi-condition classification
foreach              RTL / library iteration
for                   indexed processing
while                 repeated processing
incr                  counters / statistics
```

Example UART synthesis preparation:

```tcl
foreach rtl $RTL_LIST {

    set full_path [file join $RTL_PATH $rtl]

    if {[file exists $full_path]} {
        puts "PASS : $rtl"
    } else {
        puts "FAIL : $rtl"
    }
}
```

This is the same fundamental control-flow pattern used in the UART V3 file-list checker.

---

# Learning Result

After this module:

- conditional execution can be implemented using `if / elseif / else`,
- repeated operations can be implemented using `for`, `foreach`, and `while`,
- lists can be processed sequentially,
- PASS / FAIL counters can be created,
- Tcl control flow can be applied to RTL source checks and synthesis automation.
