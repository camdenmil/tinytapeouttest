module pwm_generator 
    #(parameter COMPARE_SIZE = 8
    ) (
    input wire clk_in, // Used for PWM counting
    input wire wr, // Used to synchronize register writes
    input wire ena,
    input wire rst_n, // active-low
    input wire [COMPARE_SIZE-1:0] compare_in,
    output reg pwm_out
);
    reg [COMPARE_SIZE-1:0] compare;
    reg [COMPARE_SIZE-1:0] counter;
    always @(posedge clk_in) begin
        if (~rst_n) begin
            counter <= 0;
            compare <= 0;
            pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1;
            // Sacrifice one step of resolution at full duty cycle to get 100%
            pwm_out <= (compare == (2**COMPARE_SIZE)-1) ? 1 : (counter < compare);
        end
    end
    always @(posedge wr) begin
        compare <= compare_in;
        if (~rst_n) begin
            counter <= 0;
            compare <= 0;
            pwm_out <= 0;
        end
        // don't reset counter, keep PWM state updating at clk_in frequencyS
    end
    always @(negedge rst_n) begin
        counter <= 0;
        compare <= 0;
        pwm_out <= 0;
    end
endmodule