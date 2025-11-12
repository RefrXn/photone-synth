module top (
    input  wire clk_50m,
    input  wire rst_n,
    
    input  wire midi_rx,
    
    input  wire BCLK,
    input  wire DACLRC,
    output wire DACDAT,
    output wire I2C_SCLK,
    inout  wire I2C_SDAT
);


    // MIDI
    wire [7:0] midi_note_A, midi_note_B;
    wire [7:0] velocity_A , velocity_B ;

    top_midi #(
        .CLK_HZ      (50_000_000),
        .BAUD        (31_250),
        .INVERT_MIDI (1'b0)
    ) u_midi (
        .clk_50m     (clk_50m),
        .rst_n       (rst_n),
        .midi_rx_ttl (midi_rx),
        .midi_note_A (midi_note_A),
        .velocity_A  (velocity_A),
        .midi_note_B (midi_note_B),
        .velocity_B  (velocity_B)
    );


    // Synth
    wire signed [15:0] synth_dry;
    wire audio_tick;
    top_synth u_synth (
        .clk_50m      (clk_50m),
        .rst_n        (rst_n),
        .audio_tick   (audio_tick),
        .midi_note_A  (midi_note_A),
        .velocity_A   (velocity_A),
        .midi_note_B  (midi_note_B),
        .velocity_B   (velocity_B),
        .audio_signal (synth_dry)
    );


    // 简易 Reverb
    wire signed [15:0] rv_in  = synth_dry;
    wire signed [15:0] rv_out;
    wire rv_ready_out;
    reg  signed [15:0] synth_wet;

    reverb u_reverb (
        .reverb_on (1'b1),
        .ready_in  (audio_tick),
        .clk_50m   (clk_50m),
        .signal_in (rv_in),
        .signal_out(rv_out),
        .ready_out (rv_ready_out)
    );

    always @(posedge clk_50m or negedge rst_n)
        if(!rst_n)
            synth_wet <= 16'sd0;
        else if(rv_ready_out)
            synth_wet <= rv_out;


    // WM8731
    wire audio_tick_codec;
    
    top_wm8731 u_codec (
        .clk_50m   (clk_50m),
        .audio_in  (synth_wet), 
        .myvalid   (audio_tick_codec),
        .DACLRC    (DACLRC),
        .BCLK      (BCLK),
        .DACDAT    (DACDAT),
        .I2C_SCLK  (I2C_SCLK),
        .I2C_SDAT  (I2C_SDAT)
    );


    // audio_tick同步
    reg [2:0] at_sync;
    always @(posedge clk_50m or negedge rst_n)
        if(!rst_n)
            at_sync <= 3'd0;
        else
            at_sync <= {at_sync[1:0], audio_tick_codec};
    assign audio_tick = (at_sync[2:1] == 2'b01);


endmodule
