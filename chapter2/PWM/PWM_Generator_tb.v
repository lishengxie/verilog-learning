`timescale 1ps/1ps
`define CLK_PERIOD 10

module PWM_Generator_tb;
    reg clk;
    reg rst_n;
    wire [7:0]led;

    initial begin
        $dumpfile("pwm_generator_tb.vcd");
        $dumpvars(0, PWM_Generator_tb);
    end

    always #(`CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;

        #(`CLK_PERIOD*2) rst_n = 1;
        #(`CLK_PERIOD*200) $stop;
    end

    PWM_Generator PWM_Generator_inst(
        .clk(clk),
        .rst_n(rst_n),
        .led(led)
    );

endmodule