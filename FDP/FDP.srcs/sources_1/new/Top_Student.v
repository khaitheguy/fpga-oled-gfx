`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk,
    input [3:0] SW,
    output sound,
    output [7:0] JB);
            
    wire new_clk;
    
    clk_6_25_mhz slow_clk (clk, new_clk);
    
    wire [15:0] pixel_data;
    wire [12:0] pixel_index;
    wire frame_begin, sending_pixels, sample_pixel;
    
    wire [1:0] bird_type;
    wire [1:0] current_fsm_state;
    wire mute;
    
    assign current_fsm_state = SW[0] ? 2 : 1;
    assign mute = SW[1];
    assign bird_type = SW[3:2];
    
    Oled_Display disp (
        .clk(new_clk),
        .reset(0),
        .pixel_data(pixel_data),
        .frame_begin(frame_begin),
        .pixel_index(pixel_index),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .cs(JB[0]),
        .sdin(JB[1]),
        .sclk(JB[3]),
        .d_cn(JB[4]),
        .resn(JB[5]),
        .vccen(JB[6]),
        .pmoden(JB[7])
        );
            
    graphics gfx (
        .clk_6p25m(new_clk),
        .pixel_index(pixel_index),
        .bird_type(bird_type),
        .current_fsm_state(current_fsm_state),
        .bird_x(10),
        .bird_y(30),
        .pig_x(70),
        .pig_y(70),
        .cursor_x(45),
        .cursor_y(30),
        .pixel_data(pixel_data)
        );
        
    
    song_player aux (
        .clk(clk),
        .mute(mute),
        .buzzer(sound)
        );

endmodule