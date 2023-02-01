module vga(
    clk,
    rst_n,
    hys,
    vys,
    rgb_data
);

input clk;
input rst_n;
output reg hys;
output reg vys;
output reg [7:0] rgb_data;

reg [31:0] cnt_hs;
wire add_cnt_hs;
wire end_cnt_hs;
reg [31:0] cnt_vs;
wire add_cnt_vs;
wire end_cnt_vs;

wire hs_rise;
wire vs_rise;
wire valid_area;
wire green_area;

reg hys_ff;
reg vys_ff;

//================Counter for HSYNC=====================
always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_hs <= 0;
    end
    else if(add_cnt_hs)begin
        if(end_cnt_hs)begin
            cnt_hs <= 0;
        end
        else begin
            cnt_hs <= cnt_hs+1;
        end
    end
end

assign add_cnt_hs = 1;
assign end_cnt_hs = add_cnt_hs && cnt_hs == 800 - 1;
//======================================================

//================Counter for VSYNC=====================
always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_vs <= 0;
    end
    else if(add_cnt_vs)begin
        if(end_cnt_vs)begin
            cnt_vs <= 0;
        end
        else begin
            cnt_vs <= cnt_vs+1;
        end
    end
end

assign add_cnt_vs = end_cnt_hs;
assign end_cnt_vs = add_cnt_vs && cnt_vs == 525 - 1;
//======================================================

// 功能代码
// hys
assign hs_rise = add_cnt_hs && cnt_hs == 10'd95;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        hys_ff <= 1;
    end
    else if(hs_rise) begin
        hys_ff <= 1;
    end
    else if(end_cnt_hs)begin
        hys_ff <= 0;
    end
end

// 和书上不同: hys需要打一拍和rgb_data对齐？
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        hys <= 1;
    end
    else begin
        hys <= hys_ff;
    end
end

// vys
assign vs_rise = add_cnt_vs && cnt_vs == 1'd1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        vys_ff <= 1;
    end
    else if(vs_rise) begin
        vys_ff <= 1;
    end
    else if(end_cnt_vs)begin
        vys_ff <= 0;
    end
end

// 和书上不同: vys需要打一拍和rgb_data对齐？
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        vys <= 1;
    end
    else begin
        vys <= hys_ff;
    end
end

// position of valid area
parameter X0 = 141;
parameter X1 = 787;
parameter Y0 = 32;
parameter Y1 = 516;
// position of green area: 
// [X_CENT-100:X_CENT+100, Y_CENT-100:Y_CENT+100]
parameter X_CENT = 464;
parameter Y_CENT = 274;
// Green and black color definition
parameter GREEN = 8'b000_111_00;
parameter BLACK = 8'b000_000_00;

assign valid_area = add_cnt_hs 
                    && cnt_hs>=X0 && cnt_hs<X1 
                    && cnt_vs>=Y0 && cnt_vs<Y1;
assign green_area = valid_area 
                    && (cnt_hs>=X_CENT-100 && cnt_hs<X_CENT+100 
                    && cnt_vs>=Y_CENT-100 && cnt_vs<Y_CENT+100);

// rgb_data
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        rgb_data <= 8'h00;
    end
    else if(valid_area) begin
        if(green_area) begin
            rgb_data <= GREEN;
        end
        else begin
            rgb_data <= BLACK;
        end
    end
    else begin
        rgb_data <= 8'h00;
    end
end

endmodule