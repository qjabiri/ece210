# Leaky Integrate-and-Fire (LIF) Neuron

This project implements a digital current-based Leaky Integrate-and-Fire (LIF) neuron model in Verilog for Tiny Tapeout.

The neuron integrates an input current over time while applying a configurable leak. When the membrane potential exceeds a threshold, the neuron emits a spike and enters a refractory period before integrating again.

The design demonstrates neuromorphic computation primitives using simple synchronous digital logic and is intended for educational and experimental purposes.

---

## How it works

At every clock cycle:

1. Input current is added to the membrane potential
2. A leak term reduces the accumulated voltage
3. If the voltage exceeds a threshold:
   - A spike is generated (`uo_out[0]`)
   - The voltage resets
   - A refractory counter prevents immediate re-spiking

---

## Pinout

### Inputs

| Pin | Name | Description |
|-----|------|-------------|
| ui[7:0] | I_in | Input current magnitude |

### Outputs

| Pin | Name | Description |
|-----|------|-------------|
| uo[0] | spike | Spike output |
| uo[7:1] | debug | Membrane potential (upper bits) |

### Bidirectional

Unused.

---

## Clock

10 MHz system clock.

---

## Applications

- Neuromorphic computing experiments
- Educational demonstrations of neuron models
- Digital spiking neural networks
- Hardware neuroscience research

---

## Author

Qudsi Aljabiri

