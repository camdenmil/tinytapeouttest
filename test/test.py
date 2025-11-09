import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from spi import SpiMaster, SpiSignals, SpiConfig




@cocotb.test()
async def test_pwm(dut):
    dut._log.info("start")

    spi_signals = SpiSignals(
        sclk = dut.sck,     # required
        mosi = dut.mosi,     # required
        miso = dut.miso,     # required
        cs   = dut.cs,      # required
        cs_active_low = True # optional (assumed True)
    )

    spi_config = SpiConfig(
        word_width = 16,
        sclk_freq  = 1e6,
        cpol       = False,
        cpha       = False,
        msb_first  = True
    )

    spi_master = SpiMaster(spi_signals, spi_config)


    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    # set the compare value
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    spi_master.write_nowait([0x007F, 0x13FF, 0x2001, 0x3000, 0x4069, 0x5010, 0x60F0, 0x70C9])

    dut._log.info("Wait 2000 cycles")
    await ClockCycles(dut.clk, 2000)
    dut.ui_in[0].value = 1

    spi_master.write_nowait([0x8001])
    dut._log.info("Wait 40000 cycles")
    await ClockCycles(dut.clk, 40000)

    spi_master.write_nowait([0x8000])
    await ClockCycles(dut.clk, 100)

    spi_master.write_nowait([0x0000, 0x1000, 0x2000, 0x3000, 0x4000, 0x5000, 0x6000, 0x7000])

    dut._log.info("Wait 2000 cycles")
    await ClockCycles(dut.clk, 2000)