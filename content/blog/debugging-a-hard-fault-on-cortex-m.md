---
title: "Debugging a Hard Fault on Cortex-M"
date: 2026-04-27
categories: ["Debugging"]
subcategories: ["Cortex-M"]
tags: ["Cortex-M", "Debugging", "ARM"]
author: "MicroHelp Team"
summary: "Your board just hard-faulted. Here's a systematic approach to decoding the fault status registers and finding the offending instruction."
---

A hard fault on a Cortex-M device can feel like a dead end — but the core gives you everything you need to find the root cause if you know where to look.

## Step 1: Read the fault status registers

Start with `CFSR`, `HFSR`, and `MMFAR`/`BFAR`. These live at fixed addresses in the System Control Block and tell you *what kind* of fault occurred — bus fault, usage fault, or memory management fault.

## Step 2: Recover the stacked PC

At the time of the fault, the core automatically pushes `xPSR`, `PC`, `LR`, `R12`, and `R0`–`R3` onto the active stack. Recovering the stacked `PC` tells you exactly which instruction triggered the fault.

```c
void HardFault_Handler(void) {
    __asm volatile (
        "tst lr, #4 \n"
        "ite eq \n"
        "mrseq r0, msp \n"
        "mrsne r0, psp \n"
        "b hard_fault_handler_c \n"
    );
}
```

## Step 3: Map the address back to source

Feed the recovered PC into `addr2line` (or your debugger's disassembly view) against the `.elf` file to get the exact source line.

## Common causes

- NULL pointer dereference
- Stack overflow corrupting adjacent memory
- Misaligned access on a peripheral register
- Executing from an invalid/erased flash address

Nine times out of ten, it's one of these four.
