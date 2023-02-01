`timescale 1ps/1ps
`define CLK_PERIOD 10

module counter1_tb;
    reg clk;
    reg rst_n;
    reg en;
    wire dout;

    initial begin
        $dumpfile("counter1.vcd");
        $dumpvars(0, counter1_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;
        en = 1;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD*3) en = 0;

        #(`CLK_PERIOD*20) $stop;
    end

    counter1 counter1_inst(
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .dout(dout)
    );

endmodule