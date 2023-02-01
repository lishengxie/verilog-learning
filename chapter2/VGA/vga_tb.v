`timescale 1ps/1ps
`define CLK_PERIOD 10

module vga_tb;
    reg clk;
    reg rst_n;

    wire hys;
    wire vys;
    wire [7:0]rgb_data;

    initial begin
        $dumpfile("vga.vcd");
        $dumpvars(0, vga_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD*500000) $stop;
    end

    vga u_vga(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hys   ( hys   ),
        .vys   ( vys   ),
        .rgb_data  ( rgb_data  )
    );


endmodule