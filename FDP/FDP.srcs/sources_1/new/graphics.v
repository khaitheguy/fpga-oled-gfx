`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 22:17:52
// Design Name: 
// Module Name: graphics
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


module graphics(
    input clk,
    input [12:0] pixel_index,
    input bird_x,
    input bird_y,
    input cursor_x,
    input cursor_y,
    output reg [15:0] pixel_data = 0
    );
    
    wire [6:0] y;
    wire [6:0] x;
    
    reg [20:0] timer_1 = 0;
    
    assign y = pixel_index / 96;
    assign x = pixel_index % 96;
    
    parameter MAX_X = 95;
    parameter MAX_Y = 63;
    
    parameter BG_W = 96;
    parameter BG_H = 64;
    
    reg [15:0] bg [0:BG_W*BG_H-1];
    
    initial begin
        $readmemh("bg.mem", bg);
    end

    reg [6:0] scroll_x = 0;
    
    always @(posedge clk) begin
        timer_1 <= (timer_1 == 1_562_500) ? 0 : timer_1 + 1;
    
        if (timer_1 == 0)
            scroll_x <= (scroll_x + 1) % 96;
    end
    
    parameter SCROLL_Y0 = 0;
    parameter SCROLL_Y1 = 38;
    
    wire [6:0] sx = (x + scroll_x) % 96;
    
    // Draw layers
    always @(posedge clk) begin
        if (y >= SCROLL_Y0 && y < SCROLL_Y1) begin
            pixel_data <= bg[y * 96 + sx];   // SCROLLED
        end else begin
            pixel_data <= bg[y * 96 + x];    // STATIC
        end
    end
    
endmodule
