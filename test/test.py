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
    dut.rst_n.value = 0
    # set the compare value
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    spi_master.write_nowait([0x007F])

    dut._log.info("Wait 1000 cycles")
    await ClockCycles(dut.clk, 1000)

    spi_master.write_nowait([0x00FF])
    await ClockCycles(dut.clk, 1000)

    spi_master.write_nowait([0x0000])
    await ClockCycles(dut.clk, 1000)

    spi_master.write_nowait([0x0001])
    await ClockCycles(dut.clk, 1000)