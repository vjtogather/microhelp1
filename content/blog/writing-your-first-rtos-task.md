---
title: "Writing Your First RTOS Task"
date: 2026-05-18
categories: ["RTOS"]
subcategories: ["FreeRTOS"]
tags: ["RTOS", "FreeRTOS", "C"]
author: "MichroHelp Team"
summary: "A practical guide to creating, scheduling, and debugging your first task on FreeRTOS — including common pitfalls with stack sizing and priorities."
---

Moving from bare-metal loops to an RTOS is one of the biggest jumps in an embedded engineer's journey. Here's how to create your first task without shooting yourself in the foot.

## Creating a task

```c
void vBlinkTask(void *pvParameters) {
    for (;;) {
        gpio_toggle(LED_PIN);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

xTaskCreate(vBlinkTask, "Blink", 128, NULL, tskIDLE_PRIORITY + 1, NULL);
```

## Common pitfalls

- **Stack too small.** `128` words might be fine for a blink task but will overflow the moment you add a `printf`. Always profile with `uxTaskGetStackHighWaterMark()`.
- **Priority inversion.** Giving every task the same priority defeats the purpose of an RTOS. Reserve higher priorities for time-critical work only.
- **Blocking in an ISR.** Never call blocking FreeRTOS APIs from an interrupt handler — use the `FromISR` variants.

## Debugging tips

Enable the FreeRTOS trace hooks or use a tool like SEGGER SystemView to visualize task switches — it turns "why is my task not running" into a five-minute investigation instead of a day of guessing.
