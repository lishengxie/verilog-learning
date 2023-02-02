module sccb(
    clk,
    rst_n,
    addr,
    wr_en,
    wdata,
    rd_en,
    rdata,
    rdata_vld,
    sclk,
    sio_out,
    sio_out_en,
    sio_din,
    rdy
);

parameter IDWADD = 8'h42;
parameter IDRADD = 8'h43;
parameter SCLK_TIME = 400;
parameter SCLK_HALF_TIME = SCLK_TIME / 2;
parameter SCLK_W_TIME = SCLK_TIME / 4;
parameter SCLK_R_TIME = (SCLK_TIME/4) * 3;

input clk;
input rst_n;
input [7:0] addr;
input wr_en;
input [7:0] wdata;
input rd_en;
output reg [7:0] rdata;
output reg rdata_vld;
output reg sclk;
output reg sio_out;
output reg sio_out_en;
input sio_din;
output reg rdy;

reg [31:0] cnt_sclk;
wire add_cnt_sclk;
wire end_cnt_sclk;

reg [31:0] cnt_byte;
wire add_cnt_byte;
wire end_cnt_byte;

reg [31:0] cnt_step;
wire add_cnt_step;
wire end_cnt_step;

reg [7:0] byte_num;
reg [7:0] step_num;

reg work_flag;
wire en;
reg rd_flag;
wire wr_state;
wire rd_state;
wire rd_0_state;
wire rd_1_state;
wire rd_get_state;

reg [7:0] subadd;
reg [7:0] wdata_ff0;
reg [29:0] wdata_tmp;
wire sclk_h2l;
wire sclk_l2h;
wire sio_send;
wire sio_get;

//===================Counter for sclk=====================
always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_sclk <= 0;
    end
    else if(add_cnt_sclk)begin
        if(end_cnt_sclk)begin
            cnt_sclk <= 0;
        end
        else begin
            cnt_sclk <= cnt_sclk + 1;
        end
    end
    else begin
        cnt_sclk <= 0;
    end
end

assign add_cnt_sclk = work_flag;
assign end_cnt_sclk = add_cnt_sclk && cnt_sclk == SCLK_TIME - 1;
//=======================================================

//==========Counter for byte in write(30)/read(21)=======
always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_byte <= 0;
    end
    else if(add_cnt_byte)begin
        if(end_cnt_byte)begin
            cnt_byte <= 0;
        end
        else begin
            cnt_byte <= cnt_byte+1;
        end
    end
end

assign add_cnt_byte = end_cnt_sclk;
assign end_cnt_byte = add_cnt_byte && cnt_byte == byte_num - 1;
//=======================================================

//=====Counter for step(used in the read process)========
always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_step <= 0;
    end
    else if(add_cnt_step)begin
        if(end_cnt_step)begin
            cnt_step <= 0;
        end
        else begin
            cnt_step <= cnt_step+1;
        end
    end
end

assign add_cnt_step = end_cnt_byte;
assign end_cnt_step = add_cnt_step && cnt_step == step_num - 1;
//=======================================================


// 功能代码
// work_flag
assign en = work_flag == 1'b0 && (wr_en || rd_en);
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        work_flag <= 1'b0;
    end
    else if(en) begin
        work_flag <= 1'b1;
    end
    else if(end_cnt_step)begin
        work_flag <= 1'b0;
    end
end

// rd_flag
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        rd_flag <= 1'b0;
    end
    else if(rd_en) begin
        rd_flag <= 1'b1;
    end
    else if(wr_en)begin
        rd_flag <= 1'b0;
    end
end

assign wr_state = work_flag && rd_flag == 1'b0;
assign rd_state = work_flag && rd_flag;
assign rd_0_state = rd_state && cnt_step == 0;
assign rd_1_state = rd_state && cnt_step == 1;
assign rd_get_state = rd_1_state && cnt_byte>=10 && cnt_byte<18;

// addr/wdata ff0
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        subadd <= 0;
        wdata_ff0 <= 0;
    end
    else if(en) begin
        subadd <= addr;
        wdata_ff0 <= wdata;
    end
end

// wdata, byte_num, step_num
always @(*) begin
    if(wr_state) begin
        wdata_tmp = {1'b0, IDWADD, 1'b1, subadd, 1'b1, wdata_ff0, 1'b1, 1'b0, 1'b1};
        byte_num = 30;
        step_num = 1;
    end
    else if(rd_0_state) begin
        wdata_tmp = {1'b0, IDWADD, 1'b1, subadd, 1'b1, 1'b0, 1'b1, 9'b0};   // read stage, fill 0 to wdata_tmp
        byte_num = 21;
        step_num = 2;
    end
    else begin 
        wdata_tmp = {1'b0, IDRADD, 1'b1, 8'b0, 1'b1, 1'b0, 1'b1, 9'b0};
        byte_num = 21;
        step_num = 2;
    end
end

// start/stop area for write/read data bytes
assign start_area = add_cnt_sclk && cnt_byte == 0;
assign stop_area = add_cnt_sclk && cnt_byte == byte_num - 1;

// sclk
assign sclk_h2l = add_cnt_sclk && cnt_sclk == 0 && ((!start_area)&&(!stop_area));
assign sclk_l2h = add_cnt_sclk && cnt_sclk==SCLK_HALF_TIME-1;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        sclk <= 1'b1;
    end
    else if(sclk_h2l) begin
        sclk <= 1'b0;
    end
    else if(sclk_l2h) begin
        sclk <= 1'b1;
    end
end

// sio_out
assign sio_send = add_cnt_sclk && cnt_sclk == SCLK_W_TIME - 1 && rd_get_state == 1'b0;
assign sio_get = add_cnt_sclk && cnt_sclk ==SCLK_R_TIME -1 && rd_get_state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        sio_out <= 1'b1;
    end
    else if(sio_send) begin
        sio_out <= wdata_tmp[29-cnt_byte];
    end
end

// sio_out_en
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        sio_out_en <= 1'b0;
    end 
    else if (work_flag && rd_get_state == 1'b0) begin
        sio_out_en <= 1'b1;
    end
    else begin
        sio_out_en <= 1'b0;
    end
end

// rdata
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        rdata <= 8'd0;
    end
    else if(rd_get_state && sio_get) begin
        rdata <= {rdata[6:0], sio_din};
    end
end

// rdata_vld
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        rdata_vld <= 1'b0;
    end
    else if(end_cnt_step && rd_1_state) begin
        rdata_vld <= 1'b1;
    end
    else begin
        rdata_vld <= 1'b0;
    end
end

// rdy
always @(*)begin
    if(work_flag || rd_en || wr_en)
        rdy = 1'b0;
    else
        rdy = 1'b1;
end

endmodule