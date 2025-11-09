module spi_interface (
    input wire miso,
    input wire sck,
    input wire cs,
    input wire rst_n,
    input wire sys_clk,
    output wire [15:0] data,
    output reg data_rdy
);
    reg [15:0] recv_buff;
    assign data = recv_buff[15:0];
    reg [4:0] recv_ctr;
    reg sck_rec;
    always @(posedge sys_clk) begin
        if (~cs && rst_n) begin
            data_rdy <= recv_ctr[4];
            if (~sck_rec && sck) begin // First clock cycle with sck rising edge
                sck_rec <= 1;
                recv_buff <= {recv_buff[14:0], miso};
                recv_ctr <= recv_ctr + 1;
            end else if (sck_rec && ~sck) begin // Falling edge
                sck_rec <= 0;
            end
        end else begin
            recv_buff <= 0;
            data_rdy <= 0;
            recv_ctr <= 0;
            sck_rec <= 0;
        end
    end
endmodule