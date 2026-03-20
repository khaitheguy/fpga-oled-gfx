`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 22:25:19
// Design Name: 
// Module Name: clk_6_25_mhz
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


module clk_6_25_mhz(
    input clk,
    output reg new_clk = 0
    );
    
    reg [2:0] count = 4'b000;
    
    always @ (posedge clk) begin
        count <= (count == 7) ? 0 : count + 1;
        new_clk <= (count == 0) ? ~new_clk : new_clk;     
    end
    
endmodule
