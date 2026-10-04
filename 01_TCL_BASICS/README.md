# 01_TCL_BASICS

Basic Tcl syntax practice for variables, output, expressions, and simple list handling.

This module is the starting point of the Tcl study repository and focuses on syntax that is later reused in EDA automation scripts.

---

## Contents

The exact Tcl files in this directory demonstrate basic Tcl language constructs such as:

- variable assignment with `set`
- variable substitution using `$`
- command substitution using `[]`
- output using `puts`
- arithmetic expressions using `expr`
- simple list creation and access

---

# 1. Running Tcl Scripts

Move to this directory:

```bash
cd ~/TCL/01_TCL_BASICS
```

Run a Tcl script with:

```bash
tclsh <script_name>.tcl
```

Example:

```bash
tclsh basic.tcl
```

The exact filename depends on the files contained in this directory.

---

# 2. Variable Assignment

Tcl variables are created using `set`.

Example:

```tcl
set design_name uart_apb
set clock_period 20.0
```

Values are read using `$`.

```tcl
puts $design_name
puts $clock_period
```

Concept:

```text
set
 ↓
store value
 ↓
$variable
 ↓
read value
```

---

# 3. Variable Substitution

Example:

```tcl
set top uart_apb

puts "Top design : $top"
```

Output:

```text
Top design : uart_apb
```

Double quotes allow variable and command substitution.

---

# 4. Command Substitution

Square brackets execute a Tcl command and substitute its result.

Example:

```tcl
set value 5

puts "Result : [expr {$value + 3}]"
```

Output:

```text
Result : 8
```

This distinction is important:

```text
"..."   → variable / command substitution enabled

{...}   → literal-style grouping

[...]   → execute Tcl command
```

---

# 5. Arithmetic Expression

Tcl arithmetic is typically performed with `expr`.

Example:

```tcl
set clock_period 20.0

set frequency_mhz [expr {1000.0 / $clock_period}]
```

Result:

```text
50.0
```

EDA connection:

```text
clock period
    ↓
expr
    ↓
clock frequency
```

---

# 6. Output with `puts`

`puts` is used frequently in automation scripts for status messages and summaries.

Example:

```tcl
puts "RTL CHECK"
puts "PASS : uart_tx.v"
puts "FAIL : uart_rx.v"
```

This becomes useful later for:

- environment checks,
- RTL source validation,
- timing summaries,
- area summaries,
- synthesis-flow logs.

---

# 7. Basic Lists

Tcl lists are frequently used to manage RTL files and design objects.

Example:

```tcl
set rtl_list {
    uart_tx.v
    uart_rx.v
    uart_core.v
}
```

Access:

```tcl
puts [lindex $rtl_list 0]
```

Count:

```tcl
puts [llength $rtl_list]
```

Example result:

```text
uart_tx.v
3
```

---

# EDA Connection

The basic commands introduced here are directly reused in synthesis automation.

```text
Tcl basic syntax        EDA use
---------------------------------------------
set                     design configuration
puts                    flow status output
expr                    clock / numeric calculation
list                    RTL source management
lindex                  individual source access
llength                 source-count checking
```

Example synthesis-style configuration:

```tcl
set TOP_DESIGN uart_apb
set CLOCK_PERIOD 20.0

set RTL_LIST {
    uart_tx.v
    uart_rx.v
    uart_core.v
}
```

This basic syntax becomes the foundation for later modules involving procedures, file I/O, regular expressions, and EDA automation.

---

# Learning Result

After this module:

- Tcl variables can be created and referenced.
- variable substitution and command substitution can be distinguished.
- arithmetic expressions can be evaluated using `expr`.
- Tcl scripts can print structured execution results.
- simple lists can be created and inspected.
- these basic commands can be applied to RTL and synthesis configuration.
