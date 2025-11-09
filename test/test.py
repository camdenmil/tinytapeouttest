import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


@cocotb.test()
async def test_pwm(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    # set the compare value
    dut.ui_in.value = 128
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Wait 1000 cycles")
    await ClockCycles(dut.clk, 512)

    dut.ui_in.value = 10
    await ClockCycles(dut.clk, 512)

    dut.ui_in.value = 255
    await ClockCycles(dut.clk, 512)