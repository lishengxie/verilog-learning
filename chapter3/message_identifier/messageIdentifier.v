module messageIdentifier(
    clk,
    rst_n,
    din,
    dout,
    dout_sop,
    dout_eop,
    dout_vld
);
    parameter HEAD = 0;
    parameter TYPE = 1;
    parameter LEN  = 2;
    parameter DATA = 3;
    parameter FCS  = 4;

    input clk;
    input rst_n;
    input [7:0] din;
    output reg [7:0] dout;
    output reg dout_sop;
    output reg dout_eop;
    output reg dout_vld;

    reg [7:0] din_ff0;

    reg [2:0] state_c;
    reg [2:0] state_n;

    reg [31:0] cnt;
    wire add_cnt;
    wire end_cnt;
    reg [15:0] x;
    reg [15:0] length;

    wire head2type_start;
    wire type2len_start;
    wire len2data_start;
    wire type2data_start;
    wire data2fcs_start;
    wire fcs2head_start;

    // 同步时序描述状态转移
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_c <= HEAD;
        end
        else begin
            state_c <= state_n;
        end
    end

    // 组合逻辑描述状态转移条件
    always @(*) begin
        case(state_c)
            HEAD: begin
                if(head2type_start) begin
                    state_n = TYPE;
                end
                else begin
                    state_n = state_c;
                end
            end
            TYPE: begin
                if(type2len_start) begin
                    state_n = LEN;
                end
                else if(type2data_start)begin
                    state_n = DATA;
                end
                else begin
                    state_n = state_c;
                end
            end
            LEN: begin
                if(len2data_start)begin
                    state_n = DATA;
                end
                else begin
                    state_n = state_c;
                end
            end
            DATA: begin
                if(data2fcs_start)begin
                    state_n = FCS;
                end
                else begin
                    state_n = state_c;
                end
            end
            FCS: begin
                if(fcs2head_start)begin
                    state_n = HEAD;
                end
                else begin
                    state_n = state_c;
                end
            end
            default: begin
                state_n = HEAD;
            end
        endcase
    end

    // assign定义转移条件
    assign head2type_start = state_c == HEAD && din_ff0 == 8'h55 && din == 8'hd5;
    assign type2len_start  = state_c == TYPE && din != 0;
    assign type2data_start = state_c == TYPE && din == 0;
    assign len2data_start  = state_c == LEN  && end_cnt;
    assign data2fcs_start  = state_c == DATA && end_cnt;
    assign fcs2head_start  = state_c == FCS  && end_cnt;

    // 功能代码
    // cnt
    always@(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cnt <= 0;
        end
        else if(add_cnt)begin
            if(end_cnt)begin
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    assign add_cnt = state_c != HEAD;
    assign end_cnt = add_cnt && cnt == x - 1;

    // din_ff0
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            din_ff0 <= 0;
        end
        else begin
            din_ff0 <= din;
        end
    end

    // length
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            length <= 0;
        end
        else if(type2data_start) begin
            length <= 64;
        end
        else if(state_c == LEN) begin
            length <= {length[7:0], din};
        end
    end

    // x
    always @(*) begin
        if(state_c == LEN) begin
            x = 2;
        end
        else if(state_c == DATA) begin
            x = length;
        end
        else if(state_c == TYPE) begin
            x = 1;
        end
        else begin
            x = 4;
        end 
    end

    // dout
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            dout <= 0;
        end
        else begin
            dout <= din;
        end
    end

    // dout_sop
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            dout_sop <= 0;
        end
        else if(state_c == TYPE) begin
            dout_sop <= 1;
        end
        else begin
            dout_sop <= 0;
        end
    end

    // dout_eop
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            dout_eop <= 0;
        end
        else if(state_c == FCS && end_cnt) begin
            dout_eop <= 1;
        end
        else begin
            dout_eop <= 0;
        end
    end

    // dout_vld
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            dout_vld <= 0;
        end
        else if(state_c != HEAD) begin
            dout_vld <= 1;
        end
        else begin
            dout_vld <= 0;
        end
    end

endmodule