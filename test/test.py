import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

SPIKE_BIT = int(os.getenv("SPIKE_BIT", "0"))

def _clean_bits(value) -> str:
    b = str(value)
    return "".join(ch if ch in "01" else "0" for ch in b)

def read_uo_bit(dut, bit_index: int) -> int:
    b = _clean_bits(dut.uo_out.value)   # "b7...b0"
    pos = 7 - bit_index                 # bit0 is last char
    return 1 if b[pos] == "1" else 0

def spike(dut) -> int:
    return read_uo_bit(dut, SPIKE_BIT)

@cocotb.test()
async def lif_behavior(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())

    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    dut.ui_in.value = 5
    for _ in range(500):
        await RisingEdge(dut.clk)
        assert spike(dut) == 0, f"Unexpected spike (uo_out[{SPIKE_BIT}]) at low input current"

    dut.ui_in.value = 255

    prev = spike(dut)
    saw_rise = False
    for _ in range(5000):
        await RisingEdge(dut.clk)
        cur = spike(dut)
        if prev == 0 and cur == 1:
            saw_rise = True
            break
        prev = cur

    assert saw_rise, f"Did not see a spike rising edge on uo_out[{SPIKE_BIT}] at high input current"

    await RisingEdge(dut.clk)
    assert spike(dut) == 0, "Spike was not a 1-cycle pulse (expected to go low the next cycle)"


    for _ in range(5):
        await RisingEdge(dut.clk)
        assert spike(dut) == 0, "Spiked again too soon (refractory not working as expected)"

