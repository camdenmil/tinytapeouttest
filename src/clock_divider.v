`default_nettype none

module clock_divider 
    #(parameter CLK_DIV_SIZE = 3
    ) (
    input wire clk, // Used for PWM counting
    input wire wr, // Used to synchronize register writes
    input wire rst_n, // active-low
    input wire [CLK_DIV_SIZE-1:0] div_in,
    output wire clk_out
);
    reg [CLK_DIV_SIZE-1:0] div;
    reg [2**CLK_DIV_SIZE:0] div_counter;
    wire div_tick = div_counter >= (1 << div) - 1;
    assign clk_out = div == 0 ? clk : div_tick;

    always @(posedge clk) begin
        if (~rst_n) begin
            div_counter <= 0;
            div <= 0;
        end else begin
            if (wr) begin
                div_counter <= 0;
                div <= div_in;
            end
            div_counter <= ~clk ? div_counter : div_tick ? 0 : div_counter + 1'b1;
        end
    end
endmodule