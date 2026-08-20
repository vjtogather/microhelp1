---
title: "Understanding the ARM Boot Sequence"
date: 2026-06-02
categories: ["Firmware"]
subcategories: ["Bootloader"]
tags: ["ARM", "Bootloader", "Firmware"]
author: "MichroHelp Team"
summary: "A walkthrough of what actually happens between power-on and your first line of C code on an ARM SoC — reset vectors, exception levels, and stack setup."
---

When you power on an ARM-based board, a lot happens before `main()` ever runs. This article walks through the boot sequence stage by stage.

## 1. Reset vector

On reset, the core fetches its first instruction from a fixed address defined by the SoC — often the start of on-chip boot ROM. This code is usually masked into silicon and cannot be changed.

## 2. Exception level and mode setup

Modern ARM cores (ARMv8-A) boot into the highest available exception level, typically EL3. Boot firmware is responsible for configuring lower exception levels and eventually handing off control down the chain — EL3 → EL2 → EL1.

## 3. Stack and C runtime setup

Before any C code can run safely, the stack pointer must be initialized and the `.bss` section zeroed. This is normally done in a small assembly stub that precedes the call into `main()` or an equivalent entry point.

## 4. Handoff to the next stage

Depending on the platform, control is passed to a second-stage bootloader (e.g. U-Boot), a hypervisor, or directly to an RTOS/bare-metal application.

Understanding this chain makes debugging early boot hangs dramatically easier — most "board doesn't boot" issues live in one of these four stages.
