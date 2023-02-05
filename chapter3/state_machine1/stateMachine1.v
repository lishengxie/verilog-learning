module stateMachine1(
    clk,
    rst_n,
    en,
    dout0,
    dout1
);
    parameter S00 = 0;
    parameter S11 = 1;
    parameter S21 = 2;
    parameter S22 = 3;
    parameter S33 = 4;

    input clk;
    input rst_n;
    input en;
    output reg[1:0] dout0;
    output reg[1:0] dout1;

    wire s002s11_start;
    wire s112s21_start;
    wire s212s22_start;
    wire s222s33_start;
    wire s332s00_start;

    reg [2:0] state_c;
    reg [2:0] state_n;
    reg [3:0] cnt;
    reg [3:0] x;
    wire add_cnt;
    wire end_cnt;

    // 同步时序描述状态转移
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_c <= S00;
        end
        else begin
            state_c <= state_n;
        end
    end

    // 组合逻辑判断状态转移条件
    always @(*) begin
        case(state_c)
            S00: begin
                if(s002s11_start)begin
                    state_n = S11;
                end
                else begin
                    state_n = state_c;
                end
            end
            S11: begin
                if(s112s21_start)begin
                    state_n = S21;
                end
                else begin
                    state_n = state_c;
                end
            end
            S21: begin
                if(s212s22_start)begin
                    state_n = S22;
                end
                else begin
                    state_n = state_c;
                end
            end
            S22: begin
                if(s222s33_start)begin
                    state_n = S33;
                end
                else begin
                    state_n = state_c;
                end
            end
            S33: begin
                if(s332s00_start)begin
                    state_n = S00;
                end
                else begin
                    state_n = state_c;
                end
            end
            default: begin
                state_n = S00;
            end
        endcase
    end

    // assign定义状态转移条件
    assign s002s11_start = state_c == S00 && end_cnt;
    assign s112s21_start = state_c == S11 && end_cnt;
    assign s212s22_start = state_c == S21 && end_cnt;
    assign s222s33_start = state_c == S22 && end_cnt;
    assign s332s00_start = state_c == S33 && end_cnt;

    // 同步时序电路设计输出
    // dout0
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            dout0 <= 0;
        end
        else if(state_c == S00) begin
            dout0 <= 0;
        end
        else if(state_c == S11 || state_c == S21) begin
            dout0 <= 1;
        end
        else if(state_c == S22) begin
            dout0 <= 2;
        end
        else if(state_c == S33) begin
            dout0 <= 3;
        end
    end

    // dout1
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            dout1 <= 0;
        end
        else if(state_c == S00) begin
            dout1 <= 0;
        end
        else if(state_c == S11) begin
            dout1 <= 1;
        end
        else if(state_c == S21 || state_c == S22) begin
            dout1 <= 2;
        end
        else if(state_c == S33) begin
            dout1 <= 3;
        end
    end

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
                cnt <= cnt +1;
            end
        end
    end

    assign add_cnt = en;
    assign end_cnt = add_cnt && cnt == x - 1;


    // x
    always @(*) begin
        if(state_c == S00)
            x = 1;
        else if(state_c == S11)
            x = 2;
        else if(state_c == S21)
            x = 2;
        else if(state_c == S22)
            x = 2;
        else
            x = 3;
    end

endmodule