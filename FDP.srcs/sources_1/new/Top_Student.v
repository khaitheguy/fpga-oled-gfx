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


module Top_Student (input clk, output [7:0] JB);
            
    wire new_clk;
    
    clk_6_25_mhz slow_clk (clk, new_clk);
    graphics gfx (
        .clk(new_clk),
        .bird_x(0),
        .bird_y(0),
        .cursor_x(0),
        .cursor_y(0),
        .JX(JB)
        );

endmodule