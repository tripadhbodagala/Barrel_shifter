// 5-bit Sequential Barrel Shifter RTL
// Shifts logically left or right by 0 to 3 positions, with load priority.

module barrel_shifter (
    input  wire       clk,
    input  wire       rst_n,      // Active-low asynchronous reset
    input  wire       load,       // Load control signal (priority over shift)
    input  wire       dir,        // Shift direction: 0 = Left, 1 = Right
    input  wire [1:0] shift,      // Shift amount (0 to 3)
    input  wire [4:0] data_in,    // 5-bit input data
    output reg  [4:0] result      // 5-bit sequential output register
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 5'b00000;
        end else if (load) begin
            result <= data_in;
        end else begin
            case (dir)
                1'b0: begin // Logical Left Shift (zero-filled from LSB)
                    case (shift)
                        2'b00: result <= result;
                        2'b01: result <= {result[3:0], 1'b0};
                        2'b10: result <= {result[2:0], 2'b00};
                        2'b11: result <= {result[1:0], 3'b000};
                    endcase
                end
                1'b1: begin // Logical Right Shift (zero-filled from MSB)
                    case (shift)
                        2'b00: result <= result;
                        2'b01: result <= {1'b0, result[4:1]};
                        2'b10: result <= {2'b00, result[4:2]};
                        2'b11: result <= {3'b000, result[4:3]};
                    endcase
                end
            endcase
        end
    end

endmodule