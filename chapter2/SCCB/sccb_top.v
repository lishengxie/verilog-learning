module sccb_top(
    clk,
    rst_n,
    addr,
    wr_en,
    wdata,
    rd_en,
    rdata,
    rdata_vld,
    sclk,
    sio_d,
    rdy
);

input clk;
input rst_n;
input [7:0] addr;
input wr_en;
input [7:0] wdata;
input rd_en;
output [7:0] rdata;
output rdata_vld;
output sclk;
inout sio_d;
output rdy;

wire sio_out;
wire sio_out_en;
wire sio_din;

// 三态门电路
assign sio_d = sio_out_en ? sio_out : 1'bz;
assign sio_din = sio_d;

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