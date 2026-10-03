# Tcl Scripting for EDA Study

Cadence **Tcl Scripting for EDA 8.6** 교재를 기반으로 Tcl 문법을 학습하고, Linux 서버 환경에서 직접 실행한 실습 코드를 정리한 repository입니다.

## Study Goal

Tcl의 기본 문법을 익히는 것에서 끝나지 않고, 반도체 설계 과정에서 사용하는 EDA Tool의 Tcl script를 이해하고 작성하는 것을 목표로 합니다.

학습 흐름:

Tcl Basics  
→ Expressions & Procedures  
→ Control Flow  
→ Strings  
→ Lists / Arrays  
→ File I/O  
→ Regular Expressions  
→ EDA Automation

## Repository Structure

- `01_TCL_BASICS`
  - Tcl command syntax
  - Variable
  - Variable substitution
  - Command substitution

- `02_EXPR_PROCEDURE`
  - Mathematical expressions
  - Bitwise operations
  - Procedure
  - Lab 4-1: Extracting Bits from Integers

- `03_CONTROL_FLOW`
  - if / elseif
  - switch
  - for
  - foreach
  - while
  - break / continue

- `04_STRING`
  - String search
  - String range
  - String conversion
  - Hexadecimal to ASCII conversion

- `05_LIST_ARRAY_DICT`
  - List
  - Array
  - foreach
  - Custom sorting
  - Design block area processing

- `06_FILE_IO`
  - File open / close
  - File read / write
  - Line-by-line processing
  - File existence check

- `07_REGEXP`
  - regexp
  - regsub
  - Text pattern matching
  - VHDL vector port parsing

- `08_EDA_AUTOMATION`
  - RTL file management
  - Library corner management
  - Project setup
  - Genus synthesis flow example

## Cadence Tcl Labs

The study follows the major labs in the Cadence Tcl Scripting for EDA 8.6 course.

### Lab 4-1 — Extracting Bits from Integers

A decimal number is converted into a 4-bit binary representation using:

- `expr`
- bitwise AND
- shift operations
- `proc`
- `if`
- `return`

### Lab 6-1 — Working with a String Bitstream

String processing concepts are studied through:

- `string first`
- `string range`
- `format`
- hexadecimal-to-ASCII conversion

### Lab 7-1 — Sorting Design Blocks

Design block information is represented using Tcl list and array structures and sorted according to area.

Main concepts:

- list
- array
- global variable
- custom comparison procedure
- `lsort`

### Lab 9-1 — VHDL Netlist Hacking

Regular expressions are used to identify and modify vector ports in a VHDL design.

Main concepts:

- file I/O
- `regexp`
- `regsub`
- netlist text processing

## Tcl and EDA Tools

EDA scripts consist of two components:

**Tcl language**

Examples:

`set`, `puts`, `foreach`, `if`, `proc`, `expr`

**EDA Tool commands**

Examples in Cadence Genus:

`read_hdl`, `elaborate`, `read_sdc`, `syn_generic`, `syn_map`, `syn_opt`

Example:

    set DESIGN cmsdk_mcu
    elaborate $DESIGN

In this example:

- `set` is a Tcl command.
- `$DESIGN` is Tcl variable substitution.
- `elaborate` is a Cadence Genus command.

## EDA Application

The Tcl syntax learned in this repository can be applied to:

- RTL file management
- Standard-cell library setup
- PVT corner handling
- SDC loading
- Synthesis automation
- Timing report parsing
- Area report parsing
- Netlist processing
- ASIC design-flow automation

## Current Design Environment

The study is performed in a Linux server environment and is connected with digital IC design exercises using:

- Tcl
- Linux
- Git / GitHub
- Cadence Genus
- Cadence Innovus

## Connection to ASIC Design Flow

Tcl is used as the scripting layer that connects repeated EDA operations.

RTL Design  
→ Functional Verification  
→ Logic Synthesis  
→ STA  
→ P&R

The final goal of this repository is to understand how Tcl can be used to make these design-flow steps reproducible and automatable.