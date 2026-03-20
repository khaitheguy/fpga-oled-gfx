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
    
    wire [15:0] pixel_data;
    wire [12:0] pixel_index;
    wire frame_begin, sending_pixels, sample_pixel;
    
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
    
    // Draw background
    assign pixel_data = 16'b00000_000000_11111;
    
endmodule
