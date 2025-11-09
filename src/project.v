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
  //assign uo_out[7:1] = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;



  wire [2:0] div_default = 3'b000;
  
  wire div_clk_out;
  wire [15:0] spi_data;
  wire data_rdy;
  wire [PWM_REG_WIDTH-1:0] pwm_compare;
  wire [3:0] dev_addr;
  reg [7:0] pwm_wr;
  wire [CLK_DIV_WIDTH-1:0] clk_div_in;
  reg clk_div_wr;
  wire [CLK_DIV_WIDTH-1:0] clk_div_reg;
  wire fast_clk;


  assign fast_clk = clk_div_reg == 0;
  assign pwm_compare = spi_data[PWM_REG_WIDTH-1:0];
  assign dev_addr[3:0] = spi_data[15:12];
  assign clk_div_in = spi_data[CLK_DIV_WIDTH-1:0];

  reg [7:0] pwm_out;
  assign uo_out = pwm_out;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
  wire _unusedui_in = &{ui_in, 8'b0};
  wire _uniseduio_in = &{uio_in[7:4], uio_in[1], 5'b0};
  wire _unusedspi = &{spi_data[11:8], 4'b0};
  //wire _unusedpwm_wr = pwm_wr[7:1];

  clock_divider #(.CLK_DIV_SIZE(CLK_DIV_WIDTH)) clkdiv (.clk (clk),
                        .wr (clk_div_wr),
                        .rst_n (rst_n),
                        .div_in (clk_div_in),
                        .clk_out (div_clk_out),
                        .div_reg (clk_div_reg));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm0 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[0]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[0]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm1 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[1]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[1]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm2 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[2]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[2]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm3 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[3]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[3]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm4 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[4]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[4]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm5 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[5]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[5]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm6 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[6]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[6]),
            .use_sys (fast_clk));
  pwm_generator #(.COMPARE_SIZE(PWM_REG_WIDTH)) pwm7 (.clk_in (div_clk_out),
            .sys_clk (clk),
            .wr (pwm_wr[7]),
            .ena (ena),
            .rst_n (rst_n),
            .compare_in (pwm_compare),
            .pwm_out (pwm_out[7]),
            .use_sys (fast_clk));
  spi_interface spi ( .miso (uio_in[2]),
                      .sck (uio_in[3]),
                      .cs (uio_in[0]),
                      .rst_n (rst_n),
                      .sys_clk (clk),
                      .data (spi_data),
                      .data_rdy (data_rdy));

  reg exec_write; // So we only do a write for one clock cycle with data_rdy

  always @(posedge clk) begin
    if (~rst_n || ~data_rdy) begin
      pwm_wr <= 0;
      clk_div_wr <= 0;
      exec_write <= 0;
    end
    if (data_rdy && ~exec_write) begin
      exec_write <= 1;
      if (dev_addr <= 4'h7) begin
        pwm_wr <= 4'b1 << dev_addr;
      end
      if (dev_addr == 4'h8) begin
        clk_div_wr <= 1;
      end
    end else begin
      clk_div_wr <= 0;
      pwm_wr <= 0;
    end
  end

endmodule
