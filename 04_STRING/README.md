# 04_STRING

Tcl string-processing practice for text inspection, comparison, extraction, and transformation.

This module focuses on Tcl string commands that are useful when handling RTL names, report text, filenames, command output, and design metadata.

---

## Contents

This directory contains examples related to:

- `string length`
- `string index`
- `string range`
- `string first`
- `string match`
- `string compare`
- `string equal`
- `string tolower`
- `string toupper`
- string validation

---

# 1. Running the Scripts

Move to this directory:

```bash
cd ~/TCL/04_STRING
```

Run a Tcl script with:

```bash
tclsh <script_name>.tcl
```

---

# 2. String Length

Example:

```tcl
set signal_name "uart_rx"

puts [string length $signal_name]
```

Output:

```text
7
```

This is useful when checking naming conventions or parsing fixed-format fields.

---

# 3. Character Access

A character can be accessed using `string index`.

```tcl
set text "UART"

puts [string index $text 0]
```

Output:

```text
U
```

Range extraction:

```tcl
puts [string range $text 1 3]
```

Output:

```text
ART
```

Concept:

```text
input string
    ↓
index / range
    ↓
selected portion
```

---

# 4. Searching Inside a String

`string first` finds the first occurrence of a substring.

```tcl
set message "ERROR: RTL file not found"

set pos [string first "RTL" $message]

puts $pos
```

If the substring is not found, Tcl returns:

```text
-1
```

Typical applications:

```text
log-message inspection
filename detection
report keyword search
simple parser construction
```

---

# 5. Pattern Matching

`string match` supports glob-style patterns.

Example:

```tcl
set filename "uart_rx.v"

if {[string match "*.v" $filename]} {
    puts "Verilog RTL"
}
```

Output:

```text
Verilog RTL
```

Other examples:

```tcl
string match "uart_*" "uart_apb"
string match "*.rpt" "timing.rpt"
string match "*FAIL*" "RESULT : FAIL"
```

---

# 6. String Comparison

Exact equality:

```tcl
set top "uart_apb"

if {[string equal $top "uart_apb"]} {
    puts "MATCH"
}
```

Output:

```text
MATCH
```

Comparison can also be performed with:

```tcl
string compare
```

Result:

```text
0   → equal
<0  → first string sorts before second
>0  → first string sorts after second
```

---

# 7. Case Conversion

Lowercase:

```tcl
puts [string tolower "UART_APB"]
```

Output:

```text
uart_apb
```

Uppercase:

```tcl
puts [string toupper "uart_apb"]
```

Output:

```text
UART_APB
```

This is useful when normalizing tool output or user-provided configuration.

---

# 8. String Validation

Tcl can validate whether a string represents a particular data type.

Example:

```tcl
set clock_period "20.0"

if {[string is double -strict $clock_period]} {
    puts "PASS : numeric value"
} else {
    puts "FAIL : invalid number"
}
```

Output:

```text
PASS : numeric value
```

This pattern is later used in command-line argument validation.

Example:

```text
09_ADVANCED/argv_basic.tcl
```

---

# 9. RTL Naming Example

Signal names are frequently processed as strings.

Example:

```tcl
set signal "uart_rx_data"

if {[string match "uart_*" $signal]} {
    puts "UART signal detected"
}
```

Another example:

```tcl
set filename "uart_apb.v"

if {[string match "*.v" $filename]} {
    puts "RTL file : $filename"
}
```

---

# EDA Connection

String processing is widely used in EDA scripting.

```text
Tcl string command      EDA application
--------------------------------------------------
string length           naming checks
string range            field extraction
string first            keyword search
string match            file / signal filtering
string equal            option comparison
string tolower          normalization
string is               input validation
```

Example flow:

```text
EDA tool output
      ↓
string search
      ↓
keyword detection
      ↓
conditional action
```

For more complex matching, these basic string commands are extended later with:

```text
regexp
regsub
```

in `07_REGEXP`.

---

# Learning Result

After this module:

- string length and individual characters can be inspected,
- portions of strings can be extracted,
- substrings can be searched,
- wildcard patterns can be matched,
- strings can be compared and normalized,
- numeric text can be validated,
- Tcl string operations can be applied to RTL names, filenames, and EDA output.
