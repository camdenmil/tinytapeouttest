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

  parameter PWM_REG_WIDTH = 8;
  parameter CLK_DIV_WIDTH = 3;
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:1] = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
  wire _unused8 = &{uio_in, 8'b0};

  wire [2:0] div_default = 3'b000;
  
  wire pwm_clk;
  wire [15:0] spi_data;
  wire data_rdy;
  wire [PWM_REG_WIDTH-1:0] pwm_compare;
  wire [2:0] pwm_addr;
  reg [7:0] pwm_wr;
  wire [CLK_DIV_WIDTH-1:0] clk_div_in;



  assign pwm_compare = spi_data[PWM_REG_WIDTH-1:0];
  assign pwm_addr[2:0] = spi_data[15:13];
  assign clk_div_in = spi_data[CLK_DIV_WIDTH-1:0];

  reg pwm_out;
  assign uo_out[0] = pwm_out;

  clock_divider #(.CLK_DIV_SIZE(CLK_DIV_WIDTH)) clkdiv (.clk (clk),
                        .wr (clk),
                        .rst_n (rst_n),
                        .div_in (div_default),
                        .clk_out (pwm_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm0 (.clk_in (pwm_clk),
            .wr (pwm_wr[0]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out));
  spi_interface spi ( .miso (uio_in[2]),
                      .sck (uio_in[3]),
                      .cs (uio_in[0]),
                      .rst_n (rst_n),
                      .data (spi_data),
                      .data_rdy (data_rdy));

  always @(posedge data_rdy) begin
    if (pwm_addr < 8) begin
      pwm_wr[pwm_addr] <= 1'b1;
    end
  end
  always @(negedge data_rdy) begin
    pwm_wr <= 0;
  end

endmodule
