module spi_interface (
    input wire miso,
    input wire sck,
    input wire cs,
    input wire rst_n,
    output wire [15:0] data,
    output reg data_rdy
);
    reg [15:0] recv_buff;
    assign data = recv_buff[15:0];
    reg [4:0] recv_ctr;
    always @(posedge sck) begin
        if (~cs) begin
            recv_buff <= {recv_buff[14:0], miso}; 
            recv_ctr <= recv_ctr + 1;
        end
    end
    always @(posedge recv_ctr[4]) begin
        data_rdy <= 1'b1;
        recv_ctr <= 0;
    end
    // Separate blocks for both edges so we remain FPGA-synthesizable
    always @(negedge cs) begin // Selected
        recv_buff <= 0;
        data_rdy <= 0;
        recv_ctr <= 0;
    end
    always @(negedge rst_n) begin
        recv_buff <= 0;
        data_rdy <= 0;
        recv_ctr <= 0;
    end
endmodule