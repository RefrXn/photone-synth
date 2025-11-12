module top_midi #(
    parameter integer CLK_HZ      = 50_000_000,
    parameter integer BAUD        = 31_250,
    parameter         INVERT_MIDI = 0
)(
    input  wire        clk_50m,
    input  wire        rst_n,
    
    input  wire        midi_rx_ttl,
    
    output reg [7:0]   midi_note_A,
    output reg [7:0]   velocity_A,
    output reg [7:0]   midi_note_B,
    output reg [7:0]   velocity_B
);


    wire         data_valid;
    wire [7:0]   data_byte;
    wire         rx_in          = INVERT_MIDI ? ~midi_rx_ttl : midi_rx_ttl;

    midi_rx #(
        .CLK_HZ    (CLK_HZ),
        .BAUD      (BAUD)
    ) u_rx (
        .clk_50m  (clk_50m),
        .rst_n    (rst_n),
        .rx       (rx_in),
        .data     (data_byte),
        .valid    (data_valid)
    );


    wire         ev_valid;
    wire         ev_on;
    wire [6:0]   ev_note;
    wire [7:0]   ev_vel;
    wire [3:0]   ev_chan;

    midi_parser u_parser (
        .clk_50m    (clk_50m),
        .rst_n      (rst_n),
        .byte_valid (data_valid),
        .byte_data  (data_byte),
        .ev_valid   (ev_valid),
        .ev_on      (ev_on),
        .ev_note    (ev_note),
        .ev_vel     (ev_vel),
        .out_chan   (ev_chan)
    );

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            midi_note_A         <= 0;
            velocity_A          <= 0;
            midi_note_B         <= 0;
            velocity_B          <= 0;
        end 
        else if (ev_valid) begin
            case (ev_chan)
                4'd0: begin
                    midi_note_A <= {1'b0, ev_note};
                    velocity_A  <= ev_on ? 8'd100 : 8'd0;
                end
                4'd1: begin
                    midi_note_B <= {1'b0, ev_note};
                    velocity_B  <= ev_on ? 8'd100 : 8'd0;
                end
            endcase
        end
    end


endmodule
