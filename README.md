# 🚌 APB RAM Design & UVM Verification

This repository contains a **SystemVerilog implementation of an APB-compliant RAM** along with a **fully structured UVM-based verification environment**.  
The project validates correct APB read/write behavior, protocol handshaking, and slave error handling.

---

## 📂 Project Structure
rtl/ → APB RAM

tb/ → UVM testbench
- configuration of environment
- transaction
- sequences
- driver
- monitor
- scoreboard
- agent
- environment
- test

---

## 📌 Design Overview

### 🔹 APB RAM
- Implements a **32 × 32-bit memory**
- Fully compliant with **AMBA APB protocol**
- Supports:
  - Read and write transfers
  - Active-low reset (`PRESETn`)
  - Address range checking
  - Slave error signaling (`PSLVERR`)
- Finite State Machine (FSM) based control:
  - `IDLE → SETUP → ACCESS → TRANSFER`

### 🔹 Key Signals
- `PSEL`, `PENABLE` — APB handshaking
- `PWRITE` — Read / Write control
- `PREADY` — Transfer completion
- `PSLVERR` — Invalid address access
- `PRDATA` / `PWDATA` — Data paths

---

## 🧠 Verification Architecture (UVM)

The testbench follows **standard UVM methodology** with clean separation of concerns.

### 🔸 Components
- **Transaction** – Encapsulates APB read/write/reset operations
- **Sequences** – Generate different traffic patterns
- **Driver** – Drives APB protocol accurately
- **Monitor** – Samples bus activity
- **Scoreboard** – Reference model with data comparison
- **Agent / Env / Test** – Modular and reusable

---

## 🔁 Verification Scenarios Covered

✔️ Valid write operations  
✔️ Valid read operations  
✔️ Write followed by read  
✔️ Bulk write → bulk read  
✔️ Slave error on invalid address (read & write)  
✔️ Reset behavior verification  

---

## 🧪 Scoreboard Highlights

- Maintains a **reference memory model**
- Checks:
  - Read data correctness
  - Proper `PSLVERR` assertion on invalid accesses
- Logs **PASS / FAIL** for every transaction

---

## 🌟 Key Takeaways

- Clean APB protocol implementation
- Strong UVM architecture
- Multiple constrained-random test scenarios
- Accurate reference modeling and checking
- Resume-ready verification project