module mixer (

    input  wire               clk_50m,
    input  wire               rst_n,
    
    input  wire               audio_tick,
    
    input  signed [15:0]      in0,
    input  signed [15:0]      in1,
                               
    output reg   signed [15:0] out
);

    reg signed [19:0] mix;

    always @(posedge clk_50m or negedge rst_n)
        if (!rst_n) out <= 0;
        else if (audio_tick) begin
            mix  = {{4{in0[15]}}, in0} + {{4{in1[15]}}, in1};
            out <= mix >>> 3; // 平均缩放防溢出 + 增益控制
        end

endmodule
