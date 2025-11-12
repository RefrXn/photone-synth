module reverb #(
    parameter [16:0] MAX_ADDR    = 17'd90000,
    parameter [16:0] D1          = 17'd21000,
    parameter [16:0] D2          = 17'd32000,
    parameter [16:0] D3          = 17'd47000,
    parameter [16:0] D4          = 17'd63000,
    parameter [16:0] D5          = 17'd54000,
    parameter [16:0] D6          = 17'd8800,
    parameter [16:0] D7          = 17'd38500,
    parameter [16:0] D8          = 17'd69500,
    // 调整衰减参数
    parameter integer FB_SHIFT   = 4,
    parameter integer SHIFT_SET1 = 4,
    parameter integer SHIFT_SET2 = 5,
    parameter integer WET_SHIFT  = 0
)(
    input        reverb_on,
    input        ready_in,
    input        clk_50m,
    input  signed [15:0] signal_in,
    output reg signed [15:0] signal_out,
    output reg   ready_out
);

    // 状态定义
    localparam [2:0]
        S_IDLE   = 3'd0,
        S_WRITE  = 3'd1,
        S_PREP1  = 3'd2,
        S_GET1   = 3'd3,
        S_PREP2  = 3'd4,
        S_GET2   = 3'd5,
        S_OUT    = 3'd6;

    reg [2:0] st;

    reg  [16:0] wptr;
    reg  [16:0] addr0, addr1, addr2, addr3;
    reg         wea;
    reg  signed [15:0] dina;
    wire signed [15:0] dout0, dout1, dout2, dout3;
    reg  signed [15:0] r0_q, r1_q, r2_q, r3_q;
    reg  signed [21:0] acc, fb_reg;   // 扩展累加器宽度防止溢出

    // 4 路延迟存储 (BRAM 宽度16bit)
    delayline u_mem0 (.addra(addr0), .clka(clk_50m), .dina(dina), .douta(dout0), .ena(1'b1), .wea(wea));
    delayline u_mem1 (.addra(addr1), .clka(clk_50m), .dina(dina), .douta(dout1), .ena(1'b1), .wea(wea));
    delayline u_mem2 (.addra(addr2), .clka(clk_50m), .dina(dina), .douta(dout2), .ena(1'b1), .wea(wea));
    delayline u_mem3 (.addra(addr3), .clka(clk_50m), .dina(dina), .douta(dout3), .ena(1'b1), .wea(wea));

    // 环形地址减法函数
    function automatic [16:0] wrap_sub;
        input [16:0] base;
        input [31:0] delta;
        reg   [17:0] ext;
        reg   [16:0] d17;
    begin
        d17      = delta[16:0];
        ext      = {1'b0, base} - {1'b0, d17};
        wrap_sub = ext[17] ? (base + (MAX_ADDR - d17)) : ext[16:0];
    end
    endfunction

    // 主状态机
    always @(posedge clk_50m) begin
        // pipeline 读出保持
        r0_q <= dout0;
        r1_q <= dout1;
        r2_q <= dout2;
        r3_q <= dout3;

        if (!reverb_on) begin
            st         <= S_IDLE;
            ready_out  <= 1'b0;
            wea        <= 1'b0;
            wptr       <= 17'd0;
            acc        <= 22'sd0;
            fb_reg     <= 22'sd0;
            signal_out <= 16'sd0;
        end else begin
            ready_out <= 1'b0;
            case (st)
                // 等待新采样
                S_IDLE: if (ready_in) begin
                    dina  <= signal_in + (fb_reg >>> FB_SHIFT);
                    addr0 <= wptr;
                    addr1 <= wptr;
                    addr2 <= wptr;
                    addr3 <= wptr;
                    wea   <= 1'b1;
                    acc   <= $signed(signal_in) >>> 1;
                    st    <= S_WRITE;
                end

                // 写入样本后切换到读延迟位置
                S_WRITE: begin
                    wea   <= 1'b0;
                    addr0 <= wrap_sub(wptr, D1);
                    addr1 <= wrap_sub(wptr, D2);
                    addr2 <= wrap_sub(wptr, D3);
                    addr3 <= wrap_sub(wptr, D4);
                    st    <= S_PREP1;
                end

                // BRAM 读延迟一拍
                S_PREP1: st <= S_GET1;

                // 第一组混响反馈叠加
                S_GET1: begin
                    acc <= acc 
                        + (($signed(r0_q)) >>> SHIFT_SET1)
                        + (($signed(r1_q)) >>> SHIFT_SET1)
                        + (($signed(r2_q)) >>> SHIFT_SET1)
                        + (($signed(r3_q)) >>> SHIFT_SET1);
                    addr0 <= wrap_sub(wptr, D5);
                    addr1 <= wrap_sub(wptr, D6);
                    addr2 <= wrap_sub(wptr, D7);
                    addr3 <= wrap_sub(wptr, D8);
                    st    <= S_PREP2;
                end

                // BRAM 读延迟一拍
                S_PREP2: st <= S_GET2;

                // 第二组混响叠加
                S_GET2: begin
                    acc <= acc
                        + (($signed(r0_q)) >>> SHIFT_SET2)
                        + (($signed(r1_q)) >>> SHIFT_SET2)
                        + (($signed(r2_q)) >>> SHIFT_SET2)
                        + (($signed(r3_q)) >>> SHIFT_SET2);
                    st  <= S_OUT;
                end

                // 输出阶段
                S_OUT: begin
                    signal_out <= $signed(acc >>> WET_SHIFT);
                    fb_reg     <= acc;
                    ready_out  <= 1'b1;
                    wptr       <= (wptr == MAX_ADDR - 1) ? 17'd0 : (wptr + 1'b1);
                    st         <= S_IDLE;
                end
            endcase
        end
    end
endmodule
