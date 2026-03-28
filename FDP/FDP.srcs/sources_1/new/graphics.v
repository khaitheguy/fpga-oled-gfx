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
    input bird_x,
    input bird_y,
    input cursor_x,
    input cursor_y,
    output [7:0] JX
    );
    
    reg [15:0] pixel_data;
    wire [12:0] pixel_index;
    wire frame_begin, sending_pixels, sample_pixel;
    
    wire [6:0] y;
    wire [6:0] x;
    
    reg [20:0] timer_1 = 0;
    
    Oled_Display disp (
        .clk(clk),
        .reset(0),
        .pixel_data(pixel_data),
        .frame_begin(frame_begin),
        .pixel_index(pixel_index),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .cs(JX[0]),
        .sdin(JX[1]),
        .sclk(JX[3]),
        .d_cn(JX[4]),
        .resn(JX[5]),
        .vccen(JX[6]),
        .pmoden(JX[7])
        );
    
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
