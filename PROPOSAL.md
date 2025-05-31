

Deep neural networks (DNNs) especially large language models (LLMs) are expanding at an unprecedented rate. In deployed systems, the principal cost driver is no longer arithmetic throughput but the energy and latency associated with transferring parameters and activations between processing elements and external memory. Continuing along a conventional digital trajectory will render future models unsustainable.

**Analog in‑memory computing (AIMC)** addresses this challenge by integrating multiply–accumulate (MAC) operations directly within dense memory arrays, thereby minimising data movement and yielding substantial reductions in both energy consumption and inference latency.

AIMC, however, introduces a new constraint: each analog dot‑product voltage must be quantised. Column‑parallel analog‑to‑digital converters (ADCs) often dictate overall power, silicon area, and latency, and each additional bit of resolution approximately doubles these costs.

This challenge invites participants to remove the high‑resolution ADC from the critical path. Specifically, every analog dot product is captured by a **1‑bit ADC**, producing a binary vector for the entire matrix–vector multiplication. The final output is reconstructed digitally via an **approximate geometric dot product**. Part of this dot product requires computational unit to calculate L2 norm of the vectors. It is computationally intensive task. A hardware accelerator can speed up this process. More importantly, an hardware accelerator can be coupled with AIMC cores to keep data local. This prevents requirement to send input vectors to a CPU.

## What You Get

* A top level verilog file with ports instantiated.
  ``` sources/L2NormAXIS.sv ```
  ```
    module L2NormAXIS(
      input         clock,
      input         reset,
      input  [63:0] io_in_tdata,
      input         io_in_tvalid,
    ...
  ```


* A verilator testbench that is ready to go.
    ``` testbench/tb.cpp ```

## Your Tasks

1. **Implement L2 Norm Accelerator**  
   Add your verilog or VHDL modules that implements L2 norm accelerator under ```sources```.
   In this challange there are 3 important metrics: Mean square error of approximation,
   latency, FPGA resource consumption.

   * `L2NormAXIS` – should be the top module name for verilator and vivado synthesis to work.
   * Top module port names should stay as it is as well.
   * Everything under the top module should be synthesizable.

2. **Synthesis, Place & Route**
   
   After finalizing the design, participants can send their design to us.
   We will synthesize your design using our local vivado license and provide you the timing and utilization report.

   If timing is failing or resource consumption is too high, further optimization is required.
   
   Design will be synthsized for Genesys 2 FPGA Board from Digilent. Keep in mind that this process might take upto an hour depending how large it is.
   
3. **Deployment**  
   In this stage, no additional effort is required. We will generate bitstream for FPGA and deploy it to prove design is working.

## Submitting

### TODO

## Leaderboard & Prize

### TODO

## References & Further Reading


* **DeepCAM: A Fully CAM-based Inference Accelerator with Variable Hash Lengths for Energy-efficient Deep Neural Networks** – Nguyen (2023)
[https://arxiv.org/abs/2302.04712](https://arxiv.org/abs/2302.04712)
* **AMBA AXI-Stream Protocol Specification**  
[https://developer.arm.com/documentation/ihi0051/latest/](https://developer.arm.com/documentation/ihi0051/latest/)
* **A Low Complexity Euclidean Norm Approximation** – Changkyu Seol (2008) [https://www.researchgate.net/publication/3320742_A_Low_Complexity_Euclidean_Norm_Approximation](https://www.researchgate.net/publication/3320742_A_Low_Complexity_Euclidean_Norm_Approximation)