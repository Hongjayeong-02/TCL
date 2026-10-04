# 05_LIST_ARRAY_DICT

Tcl collection handling practice using lists, arrays, and dictionaries.

This module focuses on data structures that are useful for managing RTL source sets, library-cell properties, hierarchy information, and structured EDA configuration.

---

## Contents

| File | Topic | Purpose |
|---|---|---|
| `list_basic.tcl` | List | Create, access, and iterate over Tcl lists |
| `array_basic.tcl` | Array | Store key/value data using Tcl arrays |
| `dict_basic.tcl` | Dictionary | Store structured metadata using Tcl dictionaries |
| `sort_by_area.tcl` | Lab 7-1 | Sort cells by area and calculate hierarchy area |

---

# 1. Running the Scripts

Move to this directory:

```bash
cd ~/TCL/05_LIST_ARRAY_DICT
```

Run examples with:

```bash
tclsh list_basic.tcl
tclsh array_basic.tcl
tclsh dict_basic.tcl
tclsh sort_by_area.tcl
```

---

# 2. Tcl List

A Tcl list stores an ordered sequence of values.

Example:

```tcl
set rtl_list {
    uart_tx.v
    uart_rx.v
    uart_core.v
}
```

Access an element:

```tcl
puts [lindex $rtl_list 0]
```

Output:

```text
uart_tx.v
```

Count elements:

```tcl
puts [llength $rtl_list]
```

Output:

```text
3
```

Append an item:

```tcl
lappend rtl_list uart_irq.v
```

Lists are heavily used in EDA Tcl for:

```text
RTL source files
library files
clock names
design objects
report values
hierarchical blocks
```

---

# 3. Tcl Array

A Tcl array stores key/value pairs.

Example:

```tcl
set block_area(NAND2X1) 2.50
set block_area(NOR2X1)  2.80
set block_area(INVX1)   1.20
set block_area(DFFRX1)  5.20
```

Read:

```tcl
puts $block_area(NAND2X1)
```

Output:

```text
2.50
```

Check whether a key exists:

```tcl
if {[info exists block_area(NAND2X1)]} {
    puts "PASS"
}
```

This is useful when cell or block properties are indexed by name.

---

# 4. Tcl Dictionary

`dict` provides another key/value data structure, especially useful for structured configuration.

Example:

```tcl
set cell_info [dict create \
    name NAND2X1 \
    area 2.50 \
    corner slow \
    voltage 0.9 \
    temperature 125]
```

Read:

```tcl
puts [dict get $cell_info area]
```

Output:

```text
2.50
```

Check a key:

```tcl
if {[dict exists $cell_info area]} {
    puts "PASS : area exists"
}
```

Add information:

```tcl
dict set cell_info library slow_vdd1v0_basicCells.lib
```

---

# 5. `dict_basic.tcl`

Run:

```bash
tclsh dict_basic.tcl
```

Example results:

```text
name NAND2X1
area 2.50
corner slow
voltage 0.9
temperature 125

PASS area exists
INFO leakage not defined

leakage 39.0345
library slow_vdd1v0_basicCells.lib
```

The example also uses nested dictionaries.

Example concept:

```text
cells
 ├── NAND2X1
 │    ├── area
 │    └── type
 ├── NOR2X1
 ├── INVX1
 └── DFFRX1
```

Example output:

```text
NAND2X1 2.50 combinational
NOR2X1 2.80 combinational
INVX1 1.20 combinational
DFFRX1 5.20 sequential

Total area : 11.70
```

---

# 6. Lab 7-1 — Sort by Area

Run:

```bash
tclsh sort_by_area.tcl
```

The exercise stores standard-cell areas and sorts cells by area.

Example cell data:

```text
INVX1   1.20
NAND2X1 2.50
NOR2X1  2.80
DFFRX1  5.20
```

Expected sorted order:

```text
INVX1
NAND2X1
NOR2X1
DFFRX1
```

---

# 7. Missing Data Check

The script uses `info exists` so that unknown cells are handled safely.

Example:

```text
WARNING : area not found for BUF_UNKNOWN
```

Instead of terminating the script, the missing entry is detected and excluded from valid area processing.

Concept:

```text
cell name
   ↓
info exists?
   ├── yes → use area
   └── no  → warning
```

---

# 8. `sort_by_area`

The procedure receives a list of cell names and returns valid cells sorted according to their area.

Concept:

```text
decoder list
    ↓
check block_area()
    ↓
remove unknown entries
    ↓
sort
    ↓
ordered cell list
```

This is useful when processing cell or block properties in an EDA script.

---

# 9. `sort_by_area2`

The extended procedure returns both the cell name and its area.

Example:

```text
{INVX1 1.2}
{NAND2X1 2.5}
{NOR2X1 2.8}
{DFFRX1 5.2}
```

This form preserves the property together with the object name.

It is useful for later report generation or additional calculations.

---

# 10. Hierarchy Area Calculation

The exercise also calculates total area for simplified hierarchy blocks.

Example output:

```text
uart_irq : 5.30
uart_rx  : 10.40
uart_tx  : 8.90
```

Conceptually:

```text
hierarchy
   ↓
cell list per block
   ↓
lookup cell area
   ↓
sum
   ↓
block total area
```

This represents a simplified version of the kind of aggregation performed when analyzing synthesis results.

---

# List vs Array vs Dict

| Data Structure | Best Use |
|---|---|
| List | Ordered sequence of RTL files or objects |
| Array | Fast key-based lookup inside a Tcl script |
| Dict | Structured configuration and metadata |

Example:

```text
RTL file sequence
    → list

cell_name → area
    → array

cell → {area, type, corner}
    → dict
```

---

# EDA Connection

These data structures map naturally to design automation.

```text
Tcl structure       EDA application
------------------------------------------------
list                RTL/file/object collection
array               cell-property lookup
dict                structured design metadata
llength             object counting
lindex              object access
lappend             dynamic source collection
lsort               ranking / report processing
info exists         property validation
```

Example synthesis-style data:

```tcl
set RTL_LIST {
    uart_tx.v
    uart_rx.v
    uart_core.v
}

set CELL_INFO [dict create \
    NAND2X1 2.50 \
    NOR2X1 2.80 \
    INVX1 1.20]
```

The same concepts are later reused in UART V3 source-file validation and synthesis-report parsing.

---

# Learning Result

After this module:

- Tcl lists can be created, extended, indexed, and iterated,
- Tcl arrays can be used for name-based property lookup,
- `info exists` can safely check whether array entries exist,
- Tcl dictionaries can store structured EDA metadata,
- objects can be sorted by numeric properties,
- hierarchy-level area can be accumulated from lower-level cell data,
- collection handling can be connected to synthesis and report automation.
