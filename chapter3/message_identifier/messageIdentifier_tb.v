`timescale 1ps/1ps
`define CLK_PERIOD 10

module messageIdentifier_tb;
    reg clk;
    reg rst_n;
    reg [7:0] din;
    wire [7:0] dout;
    wire dout_sop;
    wire dout_eop;
    wire dout_vld;

    reg [15:0] head;
    reg [7:0] pkt_type;
    reg [15:0] length;
    reg [32*8-1:0] payload_data;
    reg [64*8-1:0] payload_ctrl;
    reg [31:0] fcs;

    integer i;

    initial begin
        dump_output();
        initialize();
        clear_rst();
        write_data_packet();
        write_control_packet();
        #(`CLK_PERIOD*10) $stop;
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    task dump_output();
        begin
            $dumpfile("messageIdentifier.vcd");
            $dumpvars(0, messageIdentifier_tb);
        end
    endtask

    task initialize();
        begin
            clk             = 1;
            rst_n           = 0;
            din             = 0;
            head            = 16'h55d5;
            length          = 16'h0020;
            payload_data    = 256'habcdef;
            payload_ctrl    = 512'habcdef;
            fcs             = 32'h01011010;
        end
    endtask

    task clear_rst();
        begin
            #(`CLK_PERIOD*2) rst_n = 1;
        end
    endtask

    task write_data_packet();
        begin
            // Invalid din
            #(`CLK_PERIOD/2) din = 8'h12;
            // head
            #(`CLK_PERIOD) din = head[15:8];
            #(`CLK_PERIOD) din = head[7:0];
            // packet type
            #(`CLK_PERIOD) din = 8'h01;
            // length
            #(`CLK_PERIOD) din = length[15:8];
            #(`CLK_PERIOD) din = length[7:0];
            // data
            for (i=32;i>=1;i=i-1)begin
                #(`CLK_PERIOD) din = payload_data[(i*8-1)-: 8];
            end
            // FCS
            for (i=4;i>=1;i=i-1)begin
                #(`CLK_PERIOD) din = fcs[(i*8-1)-: 8];
            end
            // Invalid din
            #(`CLK_PERIOD) din = 8'h12;
        end
    endtask

    task write_control_packet();
        begin
            // Invalid din
            #(`CLK_PERIOD) din = 8'h12;
            // head
            #(`CLK_PERIOD) din = head[15:8];
            #(`CLK_PERIOD) din = head[7:0];
            // packet type
            #(`CLK_PERIOD) din = 8'h00;
            // data
            for (i=64;i>=1;i=i-1)begin
                #(`CLK_PERIOD) din = payload_ctrl[(i*8-1)-: 8];
            end
            // FCS
            for (i=4;i>=1;i=i-1)begin
                #(`CLK_PERIOD) din = fcs[(i*8-1)-: 8];
            end
            // Invalid din
            #(`CLK_PERIOD) din = 8'h12;
        end
    endtask


    messageIdentifier u_messageIdentifier(
        .clk      ( clk      ),
        .rst_n    ( rst_n    ),
        .din      ( din      ),
        .dout     ( dout     ),
        .dout_sop ( dout_sop ),
        .dout_eop ( dout_eop ),
        .dout_vld ( dout_vld  )
    );

endmodule
