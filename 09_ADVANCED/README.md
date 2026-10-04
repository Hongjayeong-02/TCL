# 09_ADVANCED

Advanced Tcl concepts for structuring reusable EDA automation scripts.

This directory extends the basic Tcl syntax used in previous modules and focuses on scope control, modularization, error handling, command-line arguments, and script composition.

---

## Contents

| File | Topic | Purpose |
|---|---|---|
| `upvar_uplevel.tcl` | `upvar`, `uplevel` | Access caller scope and build command wrappers |
| `namespace_basic.tcl` | `namespace` | Separate configuration and reusable procedures by scope |
| `catch_error.tcl` | `catch`, `error` | Handle failures safely in automation scripts |
| `argv_basic.tcl` | `argc`, `argv` | Pass design parameters from the command line |
| `config.tcl` | Shared configuration | Store common synthesis configuration |
| `source_main.tcl` | `source` | Load external Tcl files and structure multi-file scripts |

---

# 1. `upvar` / `uplevel`

Run:

```bash
tclsh upvar_uplevel.tcl
```

Main concepts:

```text
upvar
    ↓
access a variable in the caller's scope

uplevel
    ↓
execute a command in the caller's scope
```

Example applications:

```text
warning/error counter
area accumulation
command wrapper
EDA task execution
```

Example result:

```text
warning_count = 3
total_area = 10.50
design_name = uart_apb
RTL file count = 3
```

---

# 2. Namespace

Run:

```bash
tclsh namespace_basic.tcl
```

Namespaces prevent configuration and procedure names from colliding.

Example:

```tcl
namespace eval UART {
    variable TOP uart_apb
    variable CLOCK_MHZ 50
    variable BAUD_DIV 325
}
```

Separate namespaces are used for:

```text
UART configuration
Synthesis configuration
Reusable checking procedures
```

Example:

```text
UART::show_config
SYN::show_config
CHECK::print_result
```

This becomes useful as EDA scripts grow and multiple design environments must coexist.

---

# 3. `catch` / `error`

Run:

```bash
tclsh catch_error.tcl
```

`error` explicitly generates a Tcl error.

```tcl
error "required file not found"
```

`catch` prevents the entire automation flow from terminating immediately and allows the script to inspect the result.

```tcl
set code [catch {
    some_command
} result]
```

Typical return values:

```text
0 = success
1 = Tcl error
```

EDA applications include:

```text
missing RTL detection
missing report detection
invalid configuration detection
safe command wrappers
```

Example:

```text
RESULT : FAIL
ERROR  : couldn't open "missing_report.rpt"
```

---

# 4. `argc` / `argv`

Run without arguments:

```bash
tclsh argv_basic.tcl
```

Run with synthesis-style parameters:

```bash
tclsh argv_basic.tcl uart_apb 20.0
```

Example:

```text
TOP = uart_apb
CLOCK_PERIOD = 20.0 ns
Clock freq = 50.00 MHz
```

Command-line arguments allow the same Tcl script to be reused for different designs.

Concept:

```text
shell
   ↓
argv
   ↓
Tcl validation
   ↓
design configuration
```

---

# 5. `source`

Files:

```text
config.tcl
source_main.tcl
```

Run:

```bash
tclsh source_main.tcl
```

`config.tcl` stores project configuration:

```tcl
set TOP_DESIGN uart_apb
set CLOCK_PERIOD 20.0

set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_tx_fifo.v
    uart_rx.v
    uart_rx_fifo.v
    uart_core.v
    uart_irq.v
    uart_apb.v
}
```

`source_main.tcl` loads the configuration:

```tcl
source ./config.tcl
```

Conceptually:

```text
config.tcl
    ↓
source
    ↓
main automation script
    ↓
EDA commands
```

This is preferable to placing every setting and command in one large Tcl file.

---

# Connection to ASIC / SoC Design

These Tcl features are directly applicable to synthesis and implementation automation.

```text
namespace
    → separate project/library configuration

argv
    → select top design or clock period

source
    → separate setup, constraints, and flow scripts

catch/error
    → stop or report invalid EDA environments

upvar/uplevel
    → reusable wrappers and shared result handling
```

A larger synthesis flow can therefore be structured as:

```text
main.tcl
│
├── source config.tcl
├── source library_setup.tcl
├── source rtl_setup.tcl
├── source constraint_setup.tcl
│
├── read_hdl
├── elaborate
├── syn_generic
├── syn_map
├── syn_opt
│
└── report generation
```

---

# Learning Result

After this module:

- Tcl scope and variable handling can be controlled explicitly.
- EDA scripts can be divided into reusable files instead of one monolithic script.
- Invalid inputs and missing files can be handled safely.
- Design parameters can be supplied through command-line arguments.
- Project configuration can be isolated using namespaces.
- These concepts can be applied to UART V3 synthesis automation in Cadence Genus.
