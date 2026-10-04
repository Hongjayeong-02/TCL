# 06_FILE_IO

Tcl file I/O practice for reading, writing, parsing, and validating external files.

This module focuses on file operations that are directly useful for HDL source processing, synthesis reports, configuration files, and binary metadata extraction.

---

## Contents

This directory contains examples related to:

- `open`
- `read`
- `gets`
- `puts`
- `close`
- `file exists`
- `file join`
- filename extraction
- binary-file parsing
- Lab 6-1 bitstream metadata parsing

---

# 1. Running the Scripts

Move to this directory:

```bash
cd ~/TCL/06_FILE_IO
```

Run a Tcl script with:

```bash
tclsh <script_name>.tcl
```

Lab 6-1:

```bash
tclsh lab6_1.tcl
```

With an actual bitstream:

```bash
tclsh lab6_1.tcl <bitstream.bit>
```

---

# 2. Opening a File

A file is opened using `open`.

Example:

```tcl
set fp [open "input.txt" r]
```

Common modes:

```text
r   read
w   write
a   append
```

Always close the channel after use:

```tcl
close $fp
```

Concept:

```text
file path
   ↓
open
   ↓
channel
   ↓
read / write
   ↓
close
```

---

# 3. Reading an Entire File

Example:

```tcl
set fp [open "report.rpt" r]
set data [read $fp]
close $fp
```

This pattern is useful for:

- timing reports,
- area reports,
- RTL source files,
- configuration files.

It is reused later in `08_EDA_AUTOMATION`.

---

# 4. Reading Line by Line

`gets` reads one line at a time.

Example:

```tcl
set fp [open "rtl_list.f" r]

while {[gets $fp line] >= 0} {
    puts "RTL : $line"
}

close $fp
```

This is useful when each line represents an independent object, such as:

```text
uart_tx.v
uart_rx.v
uart_core.v
```

---

# 5. Writing a File

Example:

```tcl
set fp [open "output.txt" w]

puts $fp "uart_tx.v"
puts $fp "uart_rx.v"

close $fp
```

This pattern is later used to generate:

```text
filelist_syn.f
converted RTL
summary reports
automation output
```

---

# 6. File Existence Check

Before reading a file, the path should be validated.

Example:

```tcl
set filename "design.sdc"

if {[file exists $filename]} {
    puts "PASS : $filename"
} else {
    puts "FAIL : $filename"
}
```

This prevents unexpected runtime errors in automation scripts.

---

# 7. Path Handling

`file join` is preferred over manually concatenating directory strings.

Example:

```tcl
set rtl_path "../RTL"
set rtl_file "uart_apb.v"

set full_path [file join $rtl_path $rtl_file]
```

Result concept:

```text
../RTL
   +
uart_apb.v
   ↓
../RTL/uart_apb.v
```

Using Tcl file commands improves portability between systems.

---

# 8. Filename Extraction

Lab 6-1 includes filename extraction.

Example input:

```text
/project/fpga/build/top.bit
```

Expected result:

```text
top.bit
```

This is useful when scripts need to separate:

```text
full path
directory
filename
extension
```

without hard-coded string positions.

---

# 9. Lab 6-1 — Bitstream Parsing

Run:

```bash
tclsh lab6_1.tcl
```

Current test output includes:

```text
Stage 1
61 62 63 64 65 -> abcde

Stage 2
Path : /project/fpga/build/top.bit
Filename : top.bit

Stage 3
Usage: tclsh lab6_1.tcl <bitstream.bit>
```

The script is designed to parse metadata from an FPGA bitstream when a `.bit` file is supplied.

---

# 10. Length-Aware Parsing

The important part of the exercise is that metadata fields are not parsed by repeatedly searching for marker bytes alone.

A binary payload may legitimately contain values such as:

```text
0x61
0x62
0x63
0x64
0x65
```

Therefore, after locating the metadata section, the parser proceeds sequentially using field lengths.

Concept:

```text
field marker
    ↓
read length
    ↓
read exactly N bytes
    ↓
move to next field
```

This is safer than:

```text
search for next marker byte
```

because marker-like byte values may appear inside binary data.

---

# 11. Parsed Metadata Fields

The script is structured to handle fields such as:

```text
0x61 → design information
0x62 → FPGA part
0x63 → date
0x64 → time
0x65 → binary data section
```

The field content is processed using helper procedures such as:

```text
byte_to_uint
read_u16_be
read_string_field
hex_to_ascii
get_filename
parse_bitstream
```

This demonstrates how a larger parser can be divided into reusable functions.

---

# 12. Binary Data Handling

Binary files require more care than normal text files.

Important considerations include:

```text
byte order
field length
binary-safe reads
metadata boundaries
payload boundaries
```

The Lab 6-1 exercise is therefore useful not only for file I/O but also for learning structured binary parsing.

---

# EDA Connection

File I/O is fundamental to EDA automation.

```text
Tcl feature            EDA application
------------------------------------------------
open / read             report parsing
gets                    line-by-line source processing
puts                    generated file output
close                   channel cleanup
file exists             environment validation
file join               portable path construction
binary parsing          FPGA / tool-generated file analysis
```

Typical design-flow structure:

```text
RTL / SDC / report file
        ↓
file validation
        ↓
open
        ↓
read / parse
        ↓
process data
        ↓
generate result
```

The same concepts are later applied to:

```text
UART synthesis filelist generation
timing report parsing
area report parsing
EDA environment checking
```

---

# Learning Result

After this module:

- text files can be opened, read, written, and closed,
- files can be processed line by line,
- paths can be handled portably with Tcl file commands,
- file existence can be validated before processing,
- filenames can be extracted from full paths,
- structured binary metadata can be parsed using field lengths,
- file I/O concepts can be applied directly to synthesis and report automation.
