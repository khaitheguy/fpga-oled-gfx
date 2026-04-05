`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 23:58:25
// Design Name: 
// Module Name: audio
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module song_player #(
    parameter CLK_FREQ = 50000000, // 50 MHz
    parameter MAX_NOTES = 256
)(
    input clk,
    input mute,
    output reg buzzer
);

    // -------------------------------
    // Song data
    reg [31:0] freq_table [0:MAX_NOTES-1];
    reg [31:0] dur_table  [0:MAX_NOTES-1];
    reg [7:0] note_index;

    // Counters
    reg [31:0] counter;
    reg [31:0] toggle_limit;
    reg [31:0] duration_count;

    initial begin
        $readmemh("freq.mem", freq_table);
        $readmemh("dur.mem", dur_table);
    end

    always @(posedge clk) begin
        // -------------------------------
        // MUTE: stop everything + reset
        if (mute) begin
            note_index     <= 0;
            counter        <= 0;
            duration_count <= 0;
            buzzer         <= 0;
        end else begin
            // -------------------------------
            // Loop song continuously
            if (note_index >= MAX_NOTES) begin
                note_index <= 0;  // loop back to start
            end

            // Calculate toggle limit
            if (freq_table[note_index] != 0)
                toggle_limit <= CLK_FREQ / (freq_table[note_index] * 2);
            else
                toggle_limit <= 0;

            // -------------------------------
            // Square wave generation (with REST)
            if (freq_table[note_index] == 0) begin
                buzzer  <= 0;
                counter <= 0;
            end else if (counter >= toggle_limit) begin
                counter <= 0;
                buzzer  <= ~buzzer;
            end else begin
                counter <= counter + 1;
            end

            // -------------------------------
            // Duration control
            if (duration_count < dur_table[note_index] * (CLK_FREQ/1000)) begin
                duration_count <= duration_count + 1;
            end else begin
                duration_count <= 0;
                note_index <= note_index + 1;
            end
        end
    end

endmodule