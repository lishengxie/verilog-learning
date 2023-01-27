module PWM_Generator(
    clk,
    rst_n,
    led
);

// Hypothesis: 100 MHz system clock, 1ms corresponds to 10,000 clocks
// parameter TIME_1MS = 100_000;
// use 1 to reduce the simulation time
parameter TIME_1MS = 1;

input clk;
input rst_n;
output reg[7:0] led;

reg[31:0] cnt_1ms;
reg[31:0] cnt_10ms;
wire add_cnt_1ms;
wire end_cnt_1ms;
wire add_cnt_10ms;
wire end_cnt_10ms;
wire led_on;
wire led0_off;
wire led1_off;
wire led2_off;
wire led3_off;
wire led4_off;
wire led5_off;
wire led6_off;
wire led7_off;

//=====================Counter for period 1ms=================
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        cnt_1ms <= 0;
    end 
    else if(add_cnt_1ms)begin
        if(end_cnt_1ms)
            cnt_1ms <= 0;
        else
            cnt_1ms <= cnt_1ms + 1;
    end
end

assign add_cnt_1ms = 1'b1;
assign end_cnt_1ms = add_cnt_1ms && cnt_1ms == TIME_1MS - 1;
//============================================================

//======================Counter for 10ms======================
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        cnt_10ms <= 0;
    end
    else if(add_cnt_10ms)begin
        if(end_cnt_10ms)
            cnt_10ms <= 0;
        else
            cnt_10ms <= cnt_10ms + 1;
    end
end

assign add_cnt_10ms = end_cnt_1ms;
assign end_cnt_10ms = add_cnt_10ms && cnt_10ms == 10 - 1;
//============================================================

//功能代码
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[0] <= 0;
    end
    else if(led_on)begin
        led[0] <= 0;
    end
    else if(led0_off)begin
        led[0] <= 1;
    end
end
assign led_on = add_cnt_10ms && cnt_10ms == 10 - 1;
assign led0_off = add_cnt_10ms && cnt_10ms == 1 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[1] <= 0;
    end
    else if(led_on)begin
        led[1] <= 0;
    end
    else if(led1_off)begin
        led[1] <= 1;
    end
end
assign led1_off = add_cnt_10ms && cnt_10ms == 2 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[2] <= 0;
    end
    else if(led_on)begin
        led[2] <= 0;
    end
    else if(led2_off)begin
        led[2] <= 1;
    end
end
assign led2_off = add_cnt_10ms && cnt_10ms == 3 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[3] <= 0;
    end
    else if(led_on)begin
        led[3] <= 0;
    end
    else if(led3_off)begin
        led[3] <= 1;
    end
end
assign led3_off = add_cnt_10ms && cnt_10ms == 4 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[4] <= 0;
    end
    else if(led_on)begin
        led[4] <= 0;
    end
    else if(led4_off)begin
        led[4] <= 1;
    end
end
assign led4_off = add_cnt_10ms && cnt_10ms == 5 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[5] <= 0;
    end
    else if(led_on)begin
        led[5] <= 0;
    end
    else if(led5_off)begin
        led[5] <= 1;
    end
end
assign led5_off = add_cnt_10ms && cnt_10ms == 6 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[6] <= 0;
    end
    else if(led_on)begin
        led[6] <= 0;
    end
    else if(led6_off)begin
        led[6] <= 1;
    end
end
assign led6_off = add_cnt_10ms && cnt_10ms == 7 - 1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        led[7] <= 0;
    end
    else if(led_on)begin
        led[7] <= 0;
    end
    else if(led7_off)begin
        led[7] <= 1;
    end
end
assign led7_off = add_cnt_10ms && cnt_10ms == 8 - 1;
endmodule