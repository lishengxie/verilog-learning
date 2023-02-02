`timescale 1ps/1ps
`define CLK_PERIOD 10

module sccb_tb;

    reg clk;
    reg rst_n;
    reg [7:0] addr;
    reg wr_en;
    reg [7:0] wdata;
    reg rd_en;
    reg sio_din;
    
    wire [7:0] rdata;
    wire rdata_vld;
    wire sclk;
    wire rdy;
    wire sio_out;
    wire sio_out_en;

    initial begin
        $dumpfile("sccb_tb.vcd");
        $dumpvars(0, sccb_tb);
    end
    
    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;
        addr = 8'h24;
        wr_en = 0;
        wdata = 0;
        rd_en = 0;
        sio_din = 1;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD*400) wr_en = 1; wdata = 8'b10010110;
        #(`CLK_PERIOD) wr_en = 0;

        #(`CLK_PERIOD*400*40) rd_en = 1;
        #(`CLK_PERIOD) rd_en = 0;
        
        #(`CLK_PERIOD*400*50) $stop;
    end

    sccb u_sccb(
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .addr       ( addr       ),
        .wr_en      ( wr_en      ),
        .wdata      ( wdata      ),
        .rd_en      ( rd_en      ),
        .rdata      ( rdata      ),
        .rdata_vld  ( rdata_vld  ),
        .sclk       ( sclk       ),
        .sio_out    ( sio_out    ),
        .sio_out_en ( sio_out_en ),
        .sio_din    ( sio_din    ),
        .rdy        ( rdy        )
    );



endmodule