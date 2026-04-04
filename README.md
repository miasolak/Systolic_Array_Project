# Systolic Array for Matrix Multiplication

This project implements a parameterized **systolic array architecture** for matrix multiplication in **Verilog HDL**. The design focuses on modular processing elements, coordinated control logic, and structured data flow, with verification through simulation.

## Project Overview

The project includes:

- A parameterized systolic array for `N x N` matrix multiplication
- A modular **Processing Element (PE)**
- A **control logic** module
- A **Verilog testbench**
- A **Python script** for generating matrices and expected results

## Architecture

### `PE.v`
Implements the basic computational unit of the systolic array. Each PE receives input values, performs multiplication and accumulation, and forwards data to neighboring elements.

### `systolic_array.v`
Top-level module that connects all processing elements into the full systolic array.

### `control_logic.v`
Controls the sequencing of operations and synchronization of computation.

### `systolic_array_tb.v`
Testbench used to verify functionality and correctness through simulation.

### `matricesABC.py`
Python helper script for generating input matrices and expected multiplication results.

## How It Works

- Matrix **A** values move horizontally
- Matrix **B** values move vertically
- Each PE performs multiply-accumulate operations
- Final matrix results are produced after several clock cycles

## Features

- Parameterized and scalable design
- Modular Verilog implementation
- Separate computation and control logic
- Simulation-based verification
- Python-assisted test generation

## File Structure

```text
.
├── PE.v
├── control_logic.v
├── systolic_array.v
├── systolic_array_tb.v
└── matricesABC.py
```

## Tools and Technologies

- **Verilog HDL** for RTL design
- **Python** for matrix generation and expected outputs
- **Vivado / simulation tools** for verification

## Verification

The design was verified using a custom testbench by applying matrix inputs, simulating the system cycle by cycle, and comparing produced outputs with expected results.

## Future Improvements

- Support for larger matrix sizes
- AXI Stream / ready-valid interface support
- DMA and processor integration
- FPGA implementation and testing

## Conclusion

This project demonstrates a systolic array-based matrix multiplier in Verilog, with focus on modularity, scalability, and verification. It provides a strong foundation for further work in FPGA design and hardware acceleration.