module uart_rx(
    clk,
    rst_n,
    uart_rx,
    rx_vld,
    rx_data
);

input clk;
input rst_n;
input uart_rx;
output reg rx_vld;
output reg[7:0] rx_data;

reg [31:0] cnt1;
reg [31:0] cnt2;
wire add_cnt1;
wire end_cnt1;
wire add_cnt2;
wire end_cnt2;
reg flag;

reg uart_rx_ff0;
reg uart_rx_ff1;
reg uart_rx_ff2;

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
assign end_cnt2 = add_cnt2 && cnt2 == 9 - 1;
//===============================================

// uart rx ff
always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0) begin
        uart_rx_ff0 <= 1;
        uart_rx_ff1 <= 1;
        uart_rx_ff2 <= 1;
    end
    else begin
        uart_rx_ff0 <= uart_rx;
        uart_rx_ff1 <= uart_rx_ff0;
        uart_rx_ff2 <= uart_rx_ff1;
    end
end

// rx data
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        rx_data <= 0;
    end
    else if(cnt2>=1 && cnt2<9 && add_cnt1 && cnt1==5-1)begin
        rx_data[cnt2-1] <= uart_rx_ff2;
    end
end

//rx valid
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        rx_vld <= 0;
    end
    else if(cnt2==8 && add_cnt1 && cnt1==5-1)begin
        rx_vld <= 1;
    end
    else begin
        rx_vld <= 0;
    end
end

// flag
// 将输入的异步信号打拍后判断信号的下降沿
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        flag <= 0;
    end
    else if(uart_rx_ff2==1 && uart_rx_ff1==0) begin
        flag <= 1;
    end
    else if(end_cnt2)begin
        flag <= 0;
    end
end

endmodule