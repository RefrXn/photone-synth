module sine_rom (
    input  wire               clk_50m  ,     // 时钟信号
    input  wire        [9:0]  addr     ,     // 地址索引 0~1023
    output reg  signed [15:0] dout           // 查表输出
);

    // ROM 存储数组
    reg [15:0] rom [0:1023];

    // 初始化查找表内容（只在综合时加载进 FPGA 的 BRAM）
    // 1024 × 16-bit 有符号正弦查找表 (ROM 实现)
    initial begin
        $readmemh("sine1024.hex",rom);  // 记得设为 Memory Initialization Files
    end

    // 时钟上升沿输出数据
    always @(posedge clk_50m) begin
        dout <= $signed(rom[addr]);
    end

endmodule
