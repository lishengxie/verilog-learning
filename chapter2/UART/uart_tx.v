module uart_tx(
    clk,
    rst_n,
    tx_vld,
    tx_data,
    tx_rdy,
    uart_tx
);

input clk;
input rst_n;
input tx_vld;
input [7:0] tx_data;

output reg tx_rdy;
output reg uart_tx;

reg [31:0] cnt1;
reg [31:0] cnt2;
wire add_cnt1;
wire end_cnt1;
wire add_cnt2;
wire end_cnt2;
reg flag;

wire tx_start;
reg [9:0]tx_data_tmp;

//================counter1=======================
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if (end_cnt1) begin
            cnt1 <= 0;
        end
        else begin
            cnt1 <= cnt1 + 1;
        end
    end
end

assign add_cnt1 = flag == 1;
// 书中每一位宽度为5208, 这里为了仿真方便使用宽度10
assign end_cnt1 = add_cnt1 && cnt1 == 10 - 1;
//===============================================

//================counter2=======================
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if (end_cnt2) begin
            cnt2 <= 0;
        end
        else begin
            cnt2 <= cnt2 + 1;
        end
    end
end

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2 == 10 - 1;
//===============================================

// flag
always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag <= 0;
    end
    else if(tx_start)begin
        flag <= 1;
    end
    else if(end_cnt2)begin
        flag <= 0;
    end
end

// tx_start
assign tx_start = tx_vld && !flag;

// tx_data_tmp
always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0) begin
        tx_data_tmp <= 0;
    end
    else if(tx_start)begin
        tx_data_tmp <= {1'b1, tx_data, 1'b0};
    end
end

// uart_tx
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        uart_tx <= 0;
    end
    else if(add_cnt1 && cnt1 == 0)begin
        uart_tx <= tx_data_tmp[cnt2];
    end
end

// tx_rdy
always @(*)begin
    if(flag || tx_vld)
        tx_rdy = 0;
    else
        tx_rdy = 1;
end

endmodule