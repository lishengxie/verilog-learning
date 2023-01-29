`timescale 1ps/1ps
`define CLK_PERIOD 10

module uart_tx_tb;

    reg clk;
    reg rst_n;
    reg tx_vld;
    reg [7:0]tx_data;
    wire tx_rdy;
    wire uart_tx;

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        tx_vld = 0;
        tx_data = 0;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD);
        tx_vld = 1; 
        tx_data = 8'b01101001;
        #(`CLK_PERIOD);
        tx_vld = 0; 
        tx_data = 0;
        #(`CLK_PERIOD*200) $stop;
    end

    uart_tx u_uart_tx(
        .clk     ( clk     ),
        .rst_n   ( rst_n   ),
        .tx_vld  ( tx_vld  ),
        .tx_data ( tx_data ),
        .tx_rdy  ( tx_rdy  ),
        .uart_tx ( uart_tx  )
    );


endmodule