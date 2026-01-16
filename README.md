# Parameterized UART Transmitter in SystemVerilog

A synthesizable, parameterized UART (Universal Asynchronous Receiver-Transmitter) transmitter written in SystemVerilog, supporting standard 8N1 (8 data bits, no parity, 1 stop bit) asynchronous serial communication.

## Features

- **Fully Parameterized**:
  - `CLK_FREQ`: System clock frequency in Hz (default: `1_000_000` / 1 MHz).
  - `BAUD_RATE`: Serial communication baud rate (default: `9600` bps).
- **Accurate Baud Tick Generator**: Computes clock cycles per bit (`CLKS_PER_BIT = CLK_FREQ / BAUD_RATE`) with automatic counter bit-width resolution (`$clog2`).
- **Standard 8N1 Framing**:
  - 1 Start Bit (logic `0`)
  - 8 Data Bits (LSB first)
  - 1 Stop Bit (logic `1`)
- **Handshake Flags**:
  - `tx_start`: Active-high pulse to trigger transmission of `tx_data[7:0]`.
  - `tx_done`: Active-high 1-cycle completion pulse when the stop bit period finishes.

## State Machine Architecture

The transmitter operates using a 4-state Mealy/Moore FSM (`tx_state_t`):

1. **`TX_IDLE`**: Holds the `tx` line high (marking state). Transitions to `TX_START` upon `tx_start = 1` and registers `tx_data`.
2. **`TX_START`**: Drives `tx` low for one bit period (`CLKS_PER_BIT`).
3. **`TX_DATA`**: Shifts out 8 data bits sequentially (LSB first), advancing bit counter on each baud period.
4. **`TX_STOP`**: Drives `tx` high for one bit period, asserts `tx_done`, and returns to `TX_IDLE`.

## File Structure

```
.
├── uart_tx.sv      # Synthesizable UART transmitter module
├── tb_uart_tx.sv   # SystemVerilog simulation testbench
├── .gitignore      # Simulation and synthesis artifact ignores
└── README.md       # Project documentation
```

## Simulation

### Icarus Verilog
```bash
iverilog -g2012 -o sim_uart uart_tx.sv tb_uart_tx.sv
vvp sim_uart
```

### ModelSim / QuestaSim
```bash
vlog -sv uart_tx.sv tb_uart_tx.sv
vsim -c tb_uart_tx -do "run -all; quit"
```
