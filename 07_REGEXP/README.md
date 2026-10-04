# 07_REGEXP

Tcl regular expression and text transformation practice for RTL / EDA automation.

This module focuses on `regexp` and `regsub`, using Verilog-oriented examples instead of copied lab source files.

---

## Contents

| File | Topic | Purpose |
|---|---|---|
| `regexp_basic.tcl` | `regexp` basics | Match text patterns |
| `regsub_basic.tcl` | `regsub` basics | Replace matched text |
| `find_vector_port.tcl` | RTL parsing | Find vector-style HDL ports |
| `lab9_1.tcl` | regexp / regsub application | Parse and transform Verilog port names |

---

## 1. Basic Regular Expression

Run:

```bash
tclsh regexp_basic.tcl
```

Main concepts:

```text
regexp
pattern matching
capture groups
conditional matching
```

---

## 2. Basic Text Replacement

Run:

```bash
tclsh regsub_basic.tcl
```

Main concept:

```text
input string
    ↓
regexp pattern
    ↓
regsub
    ↓
modified string
```

---

## 3. Find Vector Ports

`find_vector_port.tcl` demonstrates how regular expressions can be applied to HDL text.

Typical Verilog vector ports:

```verilog
input      [7:0]  i_paddr;
input      [31:0] i_pwdata;
output reg [31:0] o_prdata;
```

The purpose is to detect vector declarations while ignoring scalar ports.

---

## 4. Lab 9-1

Run:

```bash
tclsh lab9_1.tcl
```

The exercise contains three stages.

### Stage 1 — `find_vector_port`

Finds vector ports from a Verilog file.

Example result:

```text
Vector ports:
  i_paddr
  i_pwdata
  o_prdata
```

### Stage 2 — `convert_netlist`

Uses `regsub -all` to rename vector signals.

Example:

```text
i_paddr
    ↓
i_paddr_bus
```

The replacement is applied to both the port declaration and internal RTL references.

Example:

```verilog
input [7:0] i_paddr_bus;

assign o_irq = i_paddr_bus[0];
```

The converted RTL is written into a separate output file.

### Stage 3 — `convert_vector`

Converts flattened vector-style names back into Verilog notation.

```text
ain_7
    ↓
ain[7]

data_15
    ↓
data[15]
```

Signals without a numeric suffix are unchanged.

```text
uart_rx
    ↓
uart_rx
```

---

## RTL-Oriented Example

The repository does not use the original VHDL lab example.

Instead, `lab9_1.tcl` creates a small UART/APB-style Verilog module for testing.

This keeps the exercise connected to the RTL design workflow used elsewhere in the portfolio.

---

## EDA Connection

Regular expressions are useful in design automation for tasks such as:

```text
RTL signal extraction
report parsing
hierarchical-name processing
netlist transformation
file-list generation
warning/error filtering
```

This module is later extended in `08_EDA_AUTOMATION`, where report text and UART synthesis data are processed automatically.
