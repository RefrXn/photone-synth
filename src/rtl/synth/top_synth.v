module top_synth (
    input  wire        clk_50m          ,
    input  wire        rst_n            ,
    input  wire        audio_tick       ,
    
    input  wire [7:0]  midi_note_A      ,
    input  wire [7:0]  midi_note_B      ,
    input  wire [7:0]  velocity_A       ,
    input  wire [7:0]  velocity_B       ,
    
    output wire [15:0] synth_dry
);

    // 常量定义
    localparam [31:0] BASE_440 = 32'h0258BF26; // A4定义

    // 频率转换
    wire [31:0] incA, incB;
    
    midi_to_freq u_mtf_1 (
        .midi_note     (midi_note_A),
        .base_freq_inc (BASE_440),
        .phase_inc     (incA)
    );
    
    midi_to_freq u_mtf_2 (
        .midi_note     (midi_note_B),
        .base_freq_inc (BASE_440),
        .phase_inc     (incB)
    );

    // 振荡器
    wire signed [15:0] sample_A, sample_B;
    
    osc u_osc_1 (
        .clk_50m       (clk_50m),
        .rst_n         (rst_n),
        .audio_tick    (audio_tick),
        .phase_inc     (incA),
        .freq_mod_q15  (0),
        .sample        (sample_A)
    );
    
    osc u_osc_2 (
        .clk_50m       (clk_50m),
        .rst_n         (rst_n),
        .audio_tick    (audio_tick),
        .phase_inc     (incB),
        .freq_mod_q15  (0),
        .sample        (sample_B)
    );

    // 混音
    mixer u_mixer (
        .clk_50m       (clk_50m),
        .rst_n         (rst_n),
        .audio_tick    (audio_tick),
        .in0           (sample_A),
        .in1           (sample_B),
        .out           (synth_dry)
    );

endmodule
