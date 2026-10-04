# 02_EXPR_PROCEDURE

Tcl expression and procedure practice for reusable automation logic.

This module focuses on numeric expressions, procedure definition, argument handling, return values, and bit-conversion exercises that are useful when building reusable EDA utility functions.

---

## Contents

This directory contains examples related to:

- `expr`
- `proc`
- procedure arguments
- `return`
- input validation
- numeric conversion
- reusable helper functions
- Lab 4-1 bit extraction

---

# 1. Running the Scripts

Move to this directory:

```bash
cd ~/TCL/02_EXPR_PROCEDURE
```

Run a Tcl script with:

```bash
tclsh <script_name>.tcl
```

Example:

```bash
tclsh lab4_1.tcl
```

---

# 2. Expressions with `expr`

Tcl arithmetic is evaluated using `expr`.

Example:

```tcl
set a 10
set b 3

set result [expr {$a + $b}]
```

Output:

```text
13
```

Common operators:

```text
+   addition
-   subtraction
*   multiplication
/   division
%   modulo
```

Comparison operators:

```text
==  equal
!=  not equal
<   less than
>   greater than
<=  less than or equal
>=  greater than or equal
```

---

# 3. Procedures

Reusable logic is defined with `proc`.

Example:

```tcl
proc add_numbers {a b} {
    return [expr {$a + $b}]
}
```

Call:

```tcl
set result [add_numbers 10 20]
puts $result
```

Output:

```text
30
```

Concept:

```text
input arguments
      ↓
procedure
      ↓
processing
      ↓
return value
```

This pattern is heavily reused later in EDA automation.

---

# 4. Procedure Arguments

A procedure can accept one or more arguments.

Example:

```tcl
proc clock_frequency {period_ns} {
    return [expr {1000.0 / $period_ns}]
}
```

Call:

```tcl
puts [clock_frequency 20.0]
```

Output:

```text
50.0
```

This is directly applicable to timing configuration.

---

# 5. Input Validation

Procedures should validate input before processing it.

Example:

```tcl
proc check_positive {value} {

    if {$value <= 0} {
        return "invalid input"
    }

    return "valid"
}
```

Validation is important in automation because invalid values should be detected before an EDA tool is executed.

Typical checks include:

```text
clock period > 0
FIFO depth > 0
numeric argument validation
valid bit-width range
existing file path
```

---

# 6. Lab 4-1 — Extracting Bits

Run:

```bash
tclsh lab4_1.tcl
```

The exercise converts integer values into binary strings.

Example:

```text
14 -> 1110b
9  -> 1001b
0  -> 0000b
15 -> 1111b
```

Invalid input is handled explicitly.

Example:

```text
Warning: value must be between 0 and 15 (18)
18 -> invalid input
```

The exercise was extended to support arbitrary widths.

Example:

```text
5 (8-bit)   -> 00000101b
14 (8-bit)  -> 00001110b
325 (9-bit) -> 101000101b
```

---

# 7. `to_bits` Procedure

The bit-conversion logic is encapsulated inside a procedure.

Concept:

```text
integer input
     ↓
range validation
     ↓
bit extraction
     ↓
binary string
     ↓
return
```

Example target behavior:

```text
to_bits 14
    ↓
1110b
```

This demonstrates how a small algorithm can be packaged as a reusable Tcl utility.

---

# 8. Extended Width Conversion

A width-aware helper can generalize the same logic.

Concept:

```text
value + width
      ↓
loop / bit extraction
      ↓
fixed-width binary string
```

Example:

```text
325
width = 9
    ↓
101000101b
```

This pattern is relevant to hardware-oriented scripting because Tcl frequently handles register values, address fields, masks, and bit widths.

---

# EDA Connection

Procedures are one of the most important Tcl features in EDA scripting.

```text
Tcl concept            EDA application
------------------------------------------------
proc                   reusable flow utilities
arguments              design parameters
return                 calculated result
expr                   timing / frequency calculation
validation             configuration checking
numeric conversion     register / bit-field handling
```

Example:

```tcl
proc calc_frequency_mhz {period_ns} {

    if {$period_ns <= 0} {
        error "clock period must be greater than zero"
    }

    return [expr {1000.0 / $period_ns}]
}
```

A procedure like this can later be reused in synthesis or timing setup scripts.

---

# Learning Result

After this module:

- arithmetic and comparison expressions can be written with `expr`,
- reusable Tcl procedures can be created,
- procedure arguments and return values can be handled,
- numeric inputs can be validated,
- integer values can be converted into hardware-oriented bit representations,
- small Tcl functions can be designed for later reuse in EDA automation.
