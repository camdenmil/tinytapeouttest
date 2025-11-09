module pwm_generator 
    #(parameter COMPARE_SIZE = 8
    ) (
    input wire clk_in, // Used for PWM counting
    input wire sys_clk,
    input wire wr, // Used to synchronize register writes
    input wire ena,
    input wire rst_n, // active-low
    input wire [COMPARE_SIZE-1:0] compare_in,
    input wire use_sys,
    output reg pwm_out
);
    reg [COMPARE_SIZE-1:0] compare;
    reg [COMPARE_SIZE-1:0] counter;
    reg atomic_reg; // Only do one write per wr cycle
    reg wait_cycle; // Track if we're waiting for a zero to start PWM'ing to avoid glitches
    always @(posedge sys_clk) begin
        if (~rst_n) begin
            counter <= 0;
            compare <= 0;
            pwm_out <= 0;
            atomic_reg <= 0;
            wait_cycle <= 0;
        end else begin
            if (wr && ~atomic_reg) begin
                compare <= compare_in;
                wait_cycle = 1'b1;
                // don't reset counter but write 0 to avoid high-duty-cycle glitches
                pwm_out <= 1'b0;
                atomic_reg <= 1'b1;
            end else if (~wr)
                atomic_reg <= 1'b0;
            if (use_sys) begin
                counter <= counter + 1'b1;
            end else if (clk_in)
                counter <= counter + 1'b1;
            
            if (counter == 0)
                wait_cycle <= 1'b0;
            if (ena && ~wait_cycle) begin
                // Sacrifice one step of resolution at full duty cycle to get 100%
                if ((compare == (2**COMPARE_SIZE)-1) || (counter < compare))
                    pwm_out <= 1;
                else
                    pwm_out <= 0;
            end else
                pwm_out <= 0;
        end
    end
endmodule