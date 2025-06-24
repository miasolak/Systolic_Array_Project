`timescale 1ns / 1ps
module PE #(
    parameter DATA_WIDTH = 32
)(
    input clk_i, reset_i, en_a_i, en_b_i, en_x_i, 
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] x_i,    
    input  [DATA_WIDTH-1:0] b_i,
    output [DATA_WIDTH-1:0] a_o, 
    output [DATA_WIDTH-1:0] b_o, 
    output [DATA_WIDTH-1:0] add_o
);
    //Internal registers
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    reg [DATA_WIDTH-1:0] x;
    
    wire [DATA_WIDTH-1:0] mul;
     
    always @(posedge clk_i or negedge reset_i) begin
        if(!reset_i) begin
            a <= 0;
            b <= 0;
            x <= 0;        
        end else begin
            if (en_a_i == 1) begin
                a <= a_i;
            end
            if (en_b_i == 1) begin
                b <= b_i;
            end
            if (en_x_i == 1) begin
                x <= x_i;
            end    
        end
    end
    
    // Pass values to the next PE
    assign a_o = a;
    assign b_o = b;  
    
    // Multiply and accumulate   
    assign mul = a * b; 
    assign add_o = mul + x;
    
endmodule   
    


    
