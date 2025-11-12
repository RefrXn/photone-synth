`timescale 1us/1ns

module tb_reverb;

    // 时钟与输入信号
    reg clk_50m;
    reg reverb_on;
    reg ready_in;
    reg signed [15:0] signal_in;
    wire signed [15:0] signal_out;
    wire ready_out;

    // 实例化 DUT
    reverb dut (
        .reverb_on(reverb_on),
        .ready_in(ready_in),
        .clk_50m(clk_50m),
        .signal_in(signal_in),
        .signal_out(signal_out),
        .ready_out(ready_out)
    );

    initial clk_50m = 0;
    always #0.5 clk_50m = ~clk_50m;  // 1MHz for simulation simplicity

    // 产生 ready_in 脉冲和正弦信号
    integer i;
    real phase;
    real freq = 1000.0; 
    real fs   = 48000.0; 
    real amp  = 10000.0;

    initial begin
        reverb_on  = 1'b0;
        ready_in   = 1'b0;
        signal_in  = 16'sd0;
        phase      = 0.0;

        // 启动延迟
        #10;
        reverb_on = 1'b1;

        // 连续送入1000个采样
        for (i = 0; i < 1000; i = i + 1) begin
            @(posedge clk_50m);
            phase = 2.0 * 3.1415926 * freq * (i / fs);
            signal_in = $rtoi(amp * $sin(phase));

            ready_in = 1'b1;
            @(posedge clk_50m);
            ready_in = 1'b0;

            // 模拟采样周期
            repeat (49) @(posedge clk_50m);
        end

        #1000;
        $finish;
    end

endmodule
