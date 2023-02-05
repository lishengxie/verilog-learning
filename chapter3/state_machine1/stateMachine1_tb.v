`timescale 1ps/1ps
`define CLK_PERIOD 10

module stateMachine1_tb;
    reg clk;
    reg rst_n;
    reg en;
    wire [1:0] dout0;
    wire [1:0] dout1;

    initial begin
        $dumpfile("state_machine1.vcd");
        $dumpvars(0, stateMachine1_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;
        en = 0;

        #(`CLK_PERIOD*2) rst_n = 1; en = 1;
        #(`CLK_PERIOD*200) $stop;
    end

    stateMachine1 u_stateMachine1(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .en    ( en    ),
        .dout0 ( dout0 ),
        .dout1 ( dout1 )
    );

endmodule