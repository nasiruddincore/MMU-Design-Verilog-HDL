# 🧠 Memory Management Unit (MMU) Design using Verilog HDL

![Verilog](https://img.shields.io/badge/Language-Verilog%20HDL-blue)
![Simulation](https://img.shields.io/badge/Simulator-Icarus%20Verilog%20%2F%20Vivado-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A parameterizable, RISC-style Memory Management Unit (MMU) designed in Verilog HDL. It supports 32-bit virtual-to-physical address translation, 4 KB pages, a 4-way set-associative Translation Lookaside Buffer (TLB) with PLRU replacement, access permissions (R/W/X, User/Supervisor), Address-Space Identifiers (ASIDs), and a Page-Table Walker (PTW) FSM.

---

## 📌 Project Overview & Features
Modern processor architectures rely on hardware-accelerated address translation and memory protection to maintain isolation between user applications and the operating system kernel. This project implements a fully functional, cycle-accurate RTL model of an MMU featuring:
* **Address Translation:** Breaks down a 32-bit virtual address into a Virtual Page Number (VPN) and a 12-bit page offset, mapping it to a Physical Page Number (PPN).
* **Set-Associative TLB:** Caches recent address translations using a tag-matching array configured with ASID context matching and pseudo-Least Recently Used (PLRU) eviction.
* **Access Permission Checker:** Combinational protection logic enforcing Read, Write, Execute, and User/Supervisor privilege validation.
* **Page-Table Walker (PTW):** A hardware state machine that handles TLB misses by fetching Page Table Entries (PTEs) over a memory bus interface.
* **Bypass Mode:** Supports unmanaged memory access when address translation is disabled.

---

## 🏗️ System Architecture & Data Flow
```text
[ CPU Request (VA, Access Type, Priv, ASID) ]
                     │
                     ▼
          [ TLB Lookup / Match? ]
             ┌───────┴───────┐
         (Hit)               (Miss)
             │               │
             ▼               ▼
      [ Permission Check ]  [ PTW FSM: Fetch PTE from BRAM ]
             │               │
      ┌──────┴──────┐        ▼
   (Pass)       (Fault) [ TLB Auto-Refill ]
      │             │        │
      ▼             ▼        └──────► [ Re-check & Output ]
[ Physical Address ] [ Exception Flag ]

📂 Folder Structure
Plaintext

MMU-Design-Verilog-HDL/
├── rtl/               # Verilog RTL source files (mmu.v, tlb.v, ptw.v, perm.v)
├── tb/                # Verification testbench and memory models (mmu_tb.v, mem_bram.v)
├── constraints/       # XDC constraints for optional FPGA prototyping
├── simulation/        # Simulation compilation outputs (.vvp executables)
├── waveforms/         # VCD trace files for waveform inspection
├── reports/           # Synthesis and utilization reports
├── docs/              # Architecture diagrams and specifications
└── README.md          # Project documentation

🚀 Setup & Execution Instructions
1. Prerequisites

Ensure you have Icarus Verilog (iverilog), the simulation runtime (vvp), and GTKWave installed and added to your system PATH.
2. Compilation and Simulation (PowerShell)

Open your terminal in the project root directory and execute the following commands:
PowerShell

# Create simulation output folder if it doesn't exist
New-Item -ItemType Directory -Force -Path "simulation"

# Compile all RTL modules, memory model, and testbench
iverilog -g2012 -o simulation/mmu_sim.vvp tb/mmu_tb.v tb/mem_bram.v rtl/tlb.v rtl/ptw.v rtl/perm.v rtl/mmu.v

# Run the simulation executable to generate waveform artifacts
vvp simulation/mmu_sim.vvp

3. Waveform Analysis

To inspect transaction traces, hit/miss timing, and fault behaviors visually, open the generated VCD file in GTKWave:
PowerShell

gtkwave mmu.vcd
