module osc (
    input  wire               clk_50m,          // 系统时钟（例如100MHz）
    input  wire               rst_n,
    input  wire               audio_tick,       // 采样tick（48kHz）
    input  wire [31:0]        phase_inc,        // 主频率相位增量
    input  wire signed [15:0] freq_mod_q15,     // 频率微调(Q15)，通常很小；为0则无调制
    output reg  signed [15:0] sample            // 16-bit采样输出
);

    // 相位寄存与频率调制 
    reg         [31:0] phase;
    wire signed [47:0] mul     = $signed({1'b0, phase_inc}) * $signed(freq_mod_q15); // 临时乘法结果
    wire        [31:0] eff_inc = phase_inc + (mul[47:15])                          ;// 右移15位，得到有效增量

    // 查表索引
    wire        [9:0]  idx     = phase[31:22];   // 1024点索引
    wire signed [15:0] lut_out               ;


    // 内部正弦表 
    sine_rom u_lut (
        .clk_50m (clk_50m)                   ,
        .addr    (idx)                       ,
        .dout    (lut_out)
    );

    // 主过程 
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            phase  <= 32'd0;
            sample <= 16'sd0;
        end else if (audio_tick) begin
            phase  <= phase + eff_inc;
            sample <= lut_out;
        end
    end

// audio_tick上升沿推进一次；可选微小频率调制freq_mod_q15（Q15）

endmodule
