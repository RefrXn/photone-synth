module midi_rx #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD   = 31_250
)(
    input  wire       clk_50m,
    input  wire       rst_n,
    
    input  wire       rx,
    
    output reg  [7:0] data,
    output reg        valid
);
    localparam OSR = 16;
    localparam TICKS_PER = CLK_HZ / (BAUD * OSR);
    localparam DIVW = 11;

    reg [DIVW-1:0] divcnt;
    reg tick16;

    always @(posedge clk_50m or negedge rst_n)
        if (!rst_n) begin
            divcnt <= 0;
            tick16 <= 0;
        end else if (divcnt == TICKS_PER - 1) begin
            divcnt <= 0;
            tick16 <= 1;
        end else begin
            divcnt <= divcnt + 1;
            tick16 <= 0;
        end

    reg rx1, rx2;
    always @(posedge clk_50m) begin
        rx1 <= rx;
        rx2 <= rx1;
    end
    wire rxs = rx2;

    reg [1:0] state;
    reg [3:0] osr;
    reg [2:0] bitn;
    reg [7:0] sh;

    localparam S_IDLE  = 0,
               S_START = 1,
               S_DATA  = 2,
               S_STOP  = 3;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            valid <= 0;
        end 
        else begin
            valid <= 0;
            if (tick16) case (state)
                S_IDLE:
                    if (!rxs) begin osr <= 0; state <= S_START; 
                    end
                S_START:
                    if (osr == 7) begin
                        if (!rxs) begin osr <= 0; bitn <= 0; state <= S_DATA; 
                        end
                        else state <= S_IDLE;
                    end 
                    else osr <= osr + 1;
                S_DATA:
                    if (osr == 15) begin
                        osr <= 0; sh <= {rxs, sh[7:1]};
                        if (bitn == 7) state <= S_STOP;
                        else bitn <= bitn + 1;
                    end 
                    else osr <= osr + 1;
                S_STOP:
                    if (osr == 15) begin
                        if (rxs) begin data <= sh; valid <= 1; 
                        end
                        state <= S_IDLE;
                    end 
                    else osr <= osr + 1;
            endcase
        end
    end
    
endmodule