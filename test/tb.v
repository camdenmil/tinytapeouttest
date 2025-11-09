`default_nettype none
`timescale 1ns / 1ps

module testbench ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("testbench.vcd");
        $dumpvars (0, testbench);
        #1;
    end

    // Wire up the inputs and outputs:
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    `ifdef GL_TEST
        wire VPWR = 1'b1;
        wire VGND = 1'b0;
    `endif


    // SPI bus to make testing easier
    wire miso;
    wire sck;
    wire mosi;
    wire cs;

    assign uio_in[0] = cs;
    assign uio_in[2] = mosi;
    assign uio_in[3] = sck;
    assign miso = 1'b0; // unused but needed to actually get the SPI lib to work

    tt_um_camdenmil_sky25b tt_um_camdenmil_sky25b (

        // Include power ports for the Gate Level test:
        `ifdef GL_TEST
            .VPWR(VPWR),
            .VGND(VGND),
        `endif

        .ui_in      (ui_in),    // Dedicated inputs
        .uo_out     (uo_out),   // Dedicated outputs
        .uio_in     (uio_in),   // IOs: Input path
        .uio_out    (uio_out),  // IOs: Output path
        .uio_oe     (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );

endmodule