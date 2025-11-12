module top_wm8731 (
    input         clk_50m,
    input  [15:0] audio_in,
    output        myvalid,

    input         DACLRC,
    input         BCLK,
    output        DACDAT,

    output        I2C_SCLK,
    inout         I2C_SDAT
);


    wire         rst_n;

    // 复位延时 65536 * 20ns
    reset_delay reset_delay_inst (
        .clk_50m(clk_50m),
        .rst_n(rst_n)
    );

    // 配置 WM8731 的寄存器
    reg_config reg_config_inst (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .i2c_sdat(I2C_SDAT),
        .i2c_sclk(I2C_SCLK)
    );

    // 发送音频数据, right justified, 16bits
    audio_out u_audio_out (
        .clk_50m(clk_50m),
        .wav_data(mic_in),
        .dacclk(DACLRC),
        .bclk(BCLK),
        .dacdat(DACDAT),
        .myvalid(myvalid)
    );

endmodule
