`timescale 1ps/1ps
`define CLK_PERIOD 10

module uart_rx_tb;

    reg clk;
    reg rst_n;
    reg uart_rx;
    reg [7:0]uart_test_data;

    wire rx_vld;
    wire [7:0]rx_data;

    integer i;

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        uart_rx = 1;
        uart_test_data = 8'b01101001;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD*10) uart_rx = 0;
        for(i=0; i<8; i=i+1) begin
            #(`CLK_PERIOD*10) uart_rx = uart_test_data[i];
        end
        #(`CLK_PERIOD*10) uart_rx = 1;
        #(`CLK_PERIOD*10) $stop;
    end

    uart_rx u_uart_rx(
        .clk     ( clk     ),
        .rst_n   ( rst_n   ),
        .uart_rx ( uart_rx ),
        .rx_vld  ( rx_vld  ),
        .rx_data ( rx_data )
    );



endmodule