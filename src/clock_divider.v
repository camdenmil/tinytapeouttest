`default_nettype none

module clock_divider 
    #(parameter CLK_DIV_SIZE = 3
    ) (
    input wire clk, // Used for PWM counting
    input wire wr, // Used to synchronize register writes
    input wire rst_n, // active-low
    input wire [CLK_DIV_SIZE-1:0] div_in,
    output reg clk_out,
    output wire div_reg
);
    reg [CLK_DIV_SIZE-1:0] div;
    reg [CLK_DIV_SIZE-1:0] div_counter;
    wire div_tick = div_counter == (1 << div) - 1;
    assign div_reg = div;
    always @(posedge clk) begin
        if (~rst_n) begin
            div_counter <= 0;
            div <= 0;
        end else begin
            if (wr) begin
                div_counter <= 0;
                div <= div_in;
            end
            div_counter <= div_tick ? 0 : div_counter + 1'b1;
            clk_out <= div_tick;
        end
    end
endmodule