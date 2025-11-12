// 把 MIDI 音符(0..127) 映射到相位增量：
// phase_inc = base_freq_inc * 2^((note - 69)/12)
// 做法：八度用移位；八度内 12 个半音用 Q16.16 查表

module midi_to_freq (
    input      [7:0]  midi_note,       // 0..127
    input      [31:0] base_freq_inc,   // A4=440Hz 对应相位增量（取决于采样率）
    
    output reg [31:0] phase_inc
);

    // 1) 计算相对 A4(69) 的偏移 
    // 用带符号的差值 Δ = note - 69
    wire signed [9:0] diff = $signed({1'b0, midi_note}) - 10'sd69;  // 范围约 -69..+58
    wire [9:0] abs_diff    = diff[9] ? (~diff + 1'b1) : diff;        // 绝对值
    wire [3:0] semi        = abs_diff % 10'd12;                       // 八度内半音 (0..11)
    wire [4:0] oct_mag     = abs_diff / 10'd12;                       // 八度数 (0..10, 实际不会太大)


    // 2) Q16.16 查表：2^(k/12) 和 2^(-k/12)
    // 常量由 round(2^(k/12) * 65536) 得到
    reg [31:0] ratio_q16;
    always @* begin
        case (semi)
            4'd0:    ratio_q16 = 32'h00010000; // 1.000000
            4'd1:    ratio_q16 = 32'h00010F39; // 1.059463
            4'd2:    ratio_q16 = 32'h00011F5A; // 1.122462
            4'd3:    ratio_q16 = 32'h00013070; // 1.189207
            4'd4:    ratio_q16 = 32'h0001428A; // 1.259921
            4'd5:    ratio_q16 = 32'h000155B8; // 1.334840
            4'd6:    ratio_q16 = 32'h00016A0A; // 1.414214
            4'd7:    ratio_q16 = 32'h00017F91; // 1.498307
            4'd8:    ratio_q16 = 32'h00019660; // 1.587401
            4'd9:    ratio_q16 = 32'h0001AE8A; // 1.681793
            4'd10:   ratio_q16 = 32'h0001C824; // 1.781797
            4'd11:   ratio_q16 = 32'h0001E343; // 1.887749
            default: ratio_q16 = 32'h00010000;
        endcase
    end

    reg [31:0] ratio_dn_q16;
    always @* begin
        case (semi)
            4'd0:    ratio_dn_q16 = 32'h00010000; // 1.000000
            4'd1:    ratio_dn_q16 = 32'h0000F1A2; // 0.943874
            4'd2:    ratio_dn_q16 = 32'h0000E412; // 0.890899
            4'd3:    ratio_dn_q16 = 32'h0000D745; // 0.840896
            4'd4:    ratio_dn_q16 = 32'h0000CB30; // 0.793701
            4'd5:    ratio_dn_q16 = 32'h0000BFC9; // 0.749154
            4'd6:    ratio_dn_q16 = 32'h0000B505; // 0.707107
            4'd7:    ratio_dn_q16 = 32'h0000AADC; // 0.667420
            4'd8:    ratio_dn_q16 = 32'h0000A145; // 0.629961
            4'd9:    ratio_dn_q16 = 32'h00009838; // 0.594604
            4'd10:   ratio_dn_q16 = 32'h00008FAD; // 0.561231
            4'd11:   ratio_dn_q16 = 32'h0000879C; // 0.529732
            default: ratio_dn_q16 = 32'h00010000;
        endcase
    end


    // 3) 先做半音比例乘法（32x32 -> 64），再右移 16 还原 
    reg [63:0] prod64;
    reg [31:0] semi_scaled;
    always @* begin
        if (!diff[9]) begin
            // diff >= 0：往上；乘以 2^(semi/12)
            prod64      = base_freq_inc * ratio_q16;
            semi_scaled = prod64[63:16];   // >> 16
        end else begin
            // diff < 0：往下；乘以 2^(-semi/12)
            prod64      = base_freq_inc * ratio_dn_q16;
            semi_scaled = prod64[63:16];   // >> 16
        end
    end


    // 4) 再按八度数移位（2^oct） 
    always @* begin
        if (!diff[9]) begin
            // 上移八度：左移
            phase_inc = semi_scaled << oct_mag;
        end else begin
            // 下移八度：右移
            phase_inc = semi_scaled >> oct_mag;
        end
    end
    
endmodule
