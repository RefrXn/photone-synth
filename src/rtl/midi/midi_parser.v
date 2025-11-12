module midi_parser(
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       byte_valid,
    input  wire [7:0] byte_data,
    
    output reg        ev_valid,
    output reg        ev_on,
    output reg [6:0]  ev_note,
    output reg [7:0]  ev_vel,
    
    output reg [3:0]  out_chan,
    output reg        cc74_valid,
    output reg [7:0]  cc74_value
);


    reg [7:0] runstat;
    reg [1:0] state;
    reg [6:0] note;
    reg [7:0] vel;
    reg [3:0] ch;

    reg [6:0] ctrl_num;
    reg [7:0] ctrl_val;

    localparam ST_IDLE      = 0,
               ST_NOTE      = 1,
               ST_VELO      = 2,
               ST_CTRL_NUM  = 3,
               ST_CTRL_VAL  = 4;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            ev_valid   <= 0;
            cc74_valid <= 0;
            state      <= ST_IDLE;
        end else begin
            ev_valid   <= 0;
            cc74_valid <= 0;
            if (byte_valid) begin
                // ignore realtime bytes >= F8
                if (byte_data >= 8'hF8) ;
                else if (byte_data[7]) begin
                    // status byte
                    runstat <= byte_data;
                    ch      <= byte_data[3:0];
                    case (byte_data[7:4])
                        4'h9, 4'h8: state <= ST_NOTE;      // Note On/Off
                        4'hB:       state <= ST_CTRL_NUM;  // Control Change
                        default:    state <= ST_IDLE;
                    endcase
                end else begin
                    // data byte
                    case (state)
                        ST_NOTE: begin
                            note  <= byte_data[6:0];
                            state <= ST_VELO;
                        end
                        ST_VELO: begin
                            vel <= byte_data;
                            ev_note   <= note;
                            ev_vel    <= vel;
                            ev_on     <= (runstat[7:4] == 4'h9) && (vel != 0);
                            out_chan  <= ch;
                            ev_valid  <= 1;
                            state     <= ST_NOTE;
                        end
                        ST_CTRL_NUM: begin
                            ctrl_num <= byte_data[6:0];
                            state    <= ST_CTRL_VAL;
                        end
                        ST_CTRL_VAL: begin
                            ctrl_val <= byte_data;
                            if (ctrl_num == 7'd74) begin
                                cc74_value <= ctrl_val;
                                cc74_valid <= 1;
                            end
                            state <= ST_CTRL_NUM;
                        end
                    endcase
                end
            end
        end
    end
endmodule