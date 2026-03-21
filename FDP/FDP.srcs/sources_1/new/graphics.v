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
    
    // Cloud dimensions
    parameter CLOUD_W = 25;
    parameter CLOUD_H = 10;
    reg [6:0] CLOUD_X = 0;
    reg [6:0] CLOUD_Y = 5;
    
    // Timer for cloud movement
    always @(posedge clk) begin
        timer_1 <= (timer_1 == 1_562_500) ? 0 : timer_1 + 1;
        
        if (timer_1 == 0) CLOUD_X <= (CLOUD_X + 1) % 96;
    end
    
    // Draw layers
    always @ (posedge clk) begin
        // Background layer: sky, grass and clouds
        if (y >= 50) pixel_data = 16'b00000_111111_00000;
        else pixel_data = 16'b00000_000000_11111;
        
        // Cloud
        if (y >= CLOUD_Y && y <= CLOUD_Y + CLOUD_H) begin
            // Compute cloud pixel relative position with modulo
            if (((x + 96 - CLOUD_X) % 96) < CLOUD_W)
                pixel_data = 16'b11111_111111_11111;
        end
    end
    
endmodule
