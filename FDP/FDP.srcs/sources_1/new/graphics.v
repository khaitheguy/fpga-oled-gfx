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
    input clk_6p25m,
    input [12:0] pixel_index,
    
    input [2:0] bird_type,
    input [2:0] current_fsm_state,  // 1=menu, 2=play, 3=replay
    
    // mouse coordinates
    input [6:0] cursor_x,
    input [5:0] cursor_y,
    
    // gameplay coordinates
    input [6:0] bird_x,
    input [5:0] bird_y,
    input [6:0] pig_x,
    input [5:0] pig_y,
    
    // future use
    input [255:0] level_map_data,

    output reg [15:0] pixel_data = 0
    );
    
    wire [6:0] y;
    wire [6:0] x;   
    
    reg [20:0] timer_1 = 0;
    
    assign y = pixel_index / 96;
    assign x = pixel_index % 96;
    
    parameter MAX_X = 95;
    parameter MAX_Y = 63;
    
    parameter TRANSPARENT = 16'hF81F;

    parameter BG_W = 96;
    parameter BG_H = 64;
    
    parameter HOME_ICON_X = 1;
    parameter HOME_ICON_Y = 1;
    
    parameter HOME_ICON_W = 9;
    parameter HOME_ICON_H = 9;
    
    parameter BIRD_W = 15;
    parameter BIRD_H = 14;
    
    parameter PIG_W = 16;
    parameter PIG_H = 15;
    
    parameter CURSOR_W = 9;
    parameter CURSOR_H = 12;
    
    reg [15:0] bg [0:BG_W*BG_H-1];
    reg [15:0] bg_title [0:BG_W*BG_H-1];
    reg [15:0] home [0:HOME_ICON_W*HOME_ICON_H-1];
    reg [15:0] bird_1 [0:BIRD_W*BIRD_H-1];
    reg [15:0] bird_2 [0:BIRD_W*BIRD_H-1];
    reg [15:0] bird_3 [0:BIRD_W*BIRD_H-1];
    reg [15:0] cursor [0:CURSOR_W*CURSOR_H-1];
    reg [15:0] pig [0:PIG_W*PIG_H-1];

    initial begin
        $readmemh("bg.mem", bg);
        $readmemh("bg_title.mem", bg_title);
        $readmemh("home.mem", home);
        $readmemh("bird_1.mem", bird_1);
        $readmemh("bird_2.mem", bird_2);
        $readmemh("bird_3.mem", bird_3);
        $readmemh("cursor.mem", cursor);
        $readmemh("pig.mem", pig);
    end

    reg [6:0] scroll_x = 0;
    
    always @(posedge clk_6p25m) begin
        timer_1 <= (timer_1 == 1_562_500) ? 0 : timer_1 + 1;
    
        if (timer_1 == 0)
            scroll_x <= (scroll_x + 1) % 96;
    end
    
    parameter SCROLL_Y0 = 0;
    parameter SCROLL_Y1 = 38;
    
    wire [6:0] sx = (x + scroll_x) % 96;
    
    // Draw layers
    always @(posedge clk_6p25m) begin
        if (current_fsm_state == 1) begin
            // menu background
            pixel_data <= bg_title[y * 96 + x];

        end else if (current_fsm_state == 2) begin
            // level background 1
            if (y >= SCROLL_Y0 && y < SCROLL_Y1)
                pixel_data <= bg[y * 96 + sx];   // SCROLLED
            else
                pixel_data <= bg[y * 96 + x];    // STATIC

            
            // bird
            if (y >= bird_y && y < bird_y + BIRD_H && x >= bird_x && x < bird_x + BIRD_W) begin
                case (bird_type)
                    3'b000:
                        if (bird_1[(y - bird_y) * BIRD_W + (x - bird_x)] != TRANSPARENT)
                            pixel_data <= bird_1[(y - bird_y) * BIRD_W + (x - bird_x)];
                    3'b001:
                        if (bird_2[(y - bird_y) * BIRD_W + (x - bird_x)] != TRANSPARENT)
                            pixel_data <= bird_2[(y - bird_y) * BIRD_W + (x - bird_x)];
                    3'b010:
                        if (bird_3[(y - bird_y) * BIRD_W + (x - bird_x)] != TRANSPARENT)
                            pixel_data <= bird_3[(y - bird_y) * BIRD_W + (x - bird_x)];
                endcase
            end
            
            // pigs
            if (y >= pig_y && y < pig_y + PIG_H && x >= pig_x && x < pig_x + PIG_W)
                if (pig[(y - pig_y) * PIG_W + (x - pig_x)] != TRANSPARENT)
                    pixel_data <= pig[(y - pig_y) * PIG_W + (x - pig_x)];
            
            // level objects
            
            // UI
            // home icon
            if (y >= HOME_ICON_Y && y < HOME_ICON_Y + HOME_ICON_H && x >= HOME_ICON_X && x < HOME_ICON_X + HOME_ICON_W) 
                pixel_data <= home[(y - HOME_ICON_Y) * HOME_ICON_W + (x - HOME_ICON_X)];
        end else if (current_fsm_state == 3) begin
            // replay screen
        end
        
        // cursor
        if (y >= cursor_y && y < cursor_y + CURSOR_H && x >= cursor_x && x < cursor_x + CURSOR_W)
            if (cursor[(y - cursor_y) * CURSOR_W + (x - cursor_x)] != TRANSPARENT)
                pixel_data <= cursor[(y - cursor_y) * CURSOR_W + (x - cursor_x)];
    end
    
endmodule
