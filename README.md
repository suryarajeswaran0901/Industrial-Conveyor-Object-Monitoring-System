# Conveyor Box Counter (Verilog / FPGA)

A Verilog implementation of a conveyor belt box counter for an **Altera Cyclone II** FPGA board. A slide switch simulates a box sensor, a counter tracks the boxes, and the conveyor motor (an LED) stops automatically when the count reaches a user-defined target.

## Features

- Switch **debouncing** (20 ms) for a clean sensor signal
- **Edge detection** so each box produces exactly one count
- 4-bit **box counter** shown on LEDs
- **Comparator** against a target set on 4 slide switches
- Automatic **motor stop** when the target is reached
- Active-low **reset** push button

## Block Diagram

```
sensor_switch --> [ Debouncer ] --> [ Edge Detector ] --> [ Counter ] --> count_leds[3:0]
                                                              |
target_val[3:0] ----------------------------------------> [ Comparator ] --> motor_led
```

## Project Structure

| Module | Description |
|--------|-------------|
| `convyer` | Top-level module. Connects all blocks and holds the counter, comparator and motor logic |
| `debouncer` | Filters switch bounce. Output changes only after the input is stable for 20 ms |
| `edge_detector` | Generates a single clock-cycle pulse on a 0 → 1 transition |

> Note: the top-level module is named `convyer` (as in the source). Keep this name consistent in your Quartus project settings, or rename it everywhere.

## How It Works

1. **Debouncer** – A raw switch produces noisy transitions. The input is first synchronized to the clock. A 20-bit counter then runs while the input differs from the output. If the input stays different for 1,000,000 clock cycles (20 ms at 50 MHz), the clean output updates.
2. **Edge Detector** – Two flip-flops store the current and previous clean values. `pulse_out = current & ~past` gives one pulse each time the sensor turns ON.
3. **Counter** – Increments on each pulse, but only while the motor is running.
4. **Comparator / Motor Control** – When `current_count >= target_val` and `target_val != 0`, the motor turns OFF. A target of `0` means no limit, so the motor keeps running.
5. **Reset** – Pressing reset (active low) clears the count to 0 and turns the motor ON.

## I/O Description

| Signal | Direction | Width | Board Resource | Description |
|--------|-----------|-------|----------------|-------------|
| `clk` | Input | 1 | 50 MHz clock | System clock |
| `reset` | Input | 1 | Push button | Active-low reset |
| `sensor_switch` | Input | 1 | Slide switch | Simulates the box sensor |
| `target_val` | Input | 4 | 4 slide switches | Target box count (0–15) |
| `count_leds` | Output | 4 | 4 red LEDs | Current box count (binary) |
| `motor_led` | Output | 1 | Green LED | ON = conveyor running, OFF = stopped |

## Usage

1. Open the project in **Quartus II** and select the Cyclone II device on your board.
2. Set `convyer` as the top-level entity.
3. Assign pins for the signals above using the Pin Planner (refer to your board's manual).
4. Compile and program the FPGA.
5. Operate the board:
   - Set the target count on `target_val`.
   - Press **reset** to start (motor LED ON, count = 0).
   - Toggle `sensor_switch` OFF → ON to simulate each box.
   - When the count reaches the target, the motor LED turns OFF.
   - Press **reset** to run again.

## Example

| Step | Action | Count LEDs | Motor LED |
|------|--------|-----------|-----------|
| 1 | Set target = 3, press reset | 0000 | ON |
| 2 | Toggle sensor (box 1) | 0001 | ON |
| 3 | Toggle sensor (box 2) | 0010 | ON |
| 4 | Toggle sensor (box 3) | 0011 | OFF (target reached) |
| 5 | Toggle sensor again | 0011 | OFF (ignored) |

## Notes and Limitations

- Maximum count and target is **15** (4-bit).
- The motor output is registered, so it reacts one clock cycle after the count changes. At 50 MHz this is not noticeable.
- Increasing `target_val` after the motor has stopped will restart the conveyor.
- Debounce time is set by the counter compare value (`1,000,000` cycles at 50 MHz = 20 ms).

## Tools

- Verilog HDL
- Intel/Altera Quartus II
- Cyclone II FPGA development board

## Author

Surya


