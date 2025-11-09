`default_nettype none

module tt_um_camdenmil_sky25b (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset

);
  parameter COMPARE_SIZE = 8;
  parameter CLK_DIV_SIZE = 3;

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:1] = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
  wire _unused8 = &{uio_in, 8'b0};


  reg pwm_out;
  assign uo_out[0] = pwm_out;

  reg [COMPARE_SIZE-1:0] compare;
  reg [COMPARE_SIZE-1:0] counter;
  reg [CLK_DIV_SIZE-1:0] div;
  reg [CLK_DIV_SIZE-1:0] div_counter;

  assign compare[7:0] = ui_in[7:0];

  wire div_tick = (div_counter == div);

  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
      div_counter <= 0;
      div <= 0;
    end else begin
      div_counter <= div_tick ? 0 : div_counter + 1'b1;
      counter     <= div_tick ? counter + 1'b1 : counter;
      // Sacrifice one step of resolution at full duty cycle to get 100%
      pwm_out <= (compare == (2**COMPARE_SIZE)-1) ? 1 : (counter < compare);
    end
  end
endmodule
