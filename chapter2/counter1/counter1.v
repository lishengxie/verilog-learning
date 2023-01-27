module counter1(
    clk,        // 时钟
    rst_n,      // 复位
    en,
    dout        
);

input clk;
input rst_n;
input en;
output reg dout;

reg[3:0] cnt;
reg[3:0] cnt_c;
reg[3:0] x; 
reg[3:0] y;
wire add_cnt;
wire end_cnt;
wire add_cnt_c;
wire end_cnt_c;
reg flag;
wire dout_l2h;

//====================计数器1===================
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        cnt <= 0;
    end
    else if (add_cnt)begin
        if (end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

// 计数器1加法和归0条件
assign add_cnt = (flag==1'b1);
assign end_cnt = add_cnt && (cnt==x+y-1);
//=============================================

//====================计数器2===================
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        cnt_c <= 0; 
    end
    else if(add_cnt_c) begin
        if(end_cnt_c)begin
            cnt_c <= 0;
        end
        else 
            cnt_c <= cnt_c + 1;
    end
end

// 计数器2加法和归0条件
assign add_cnt_c = end_cnt;
assign end_cnt_c = add_cnt_c && cnt_c == 4-1; 
//==============================================

//============功能代码===========================
always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(dout_l2h)begin
        dout <= 1;
    end
    else if(end_cnt)begin
        dout <= 0;
    end
end

assign dout_l2h = add_cnt & cnt == x-1;

// flag定义
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        flag <= 0;
    end
    else if(en)begin
        flag <= 1;
    end
    else if(end_cnt_c)begin
        flag <= 0;
    end
end

// x,y 定义
always @(*) begin
    if(cnt_c == 0)begin
        x = 1;
        y = 1;
    end
    else if(cnt_c == 1)begin
        x = 1;
        y = 2;
    end
    else if(cnt_c == 2)begin
        x = 1;
        y = 3;
    end
    else if(cnt_c == 3)begin
        x = 1;
        y = 4;
    end
    else begin
        x = 0;
        y = 0;
    end
end
//=============================================

endmodule