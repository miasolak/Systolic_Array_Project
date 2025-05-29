`timescale 1ns / 1ps
module PE #(
    parameter DATA_WIDTH = 32
)(
    input clk_i, reset_i, en_a_i, en_b_i, en_x_i, 
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] x_i,      //jel treba wire za input?? PITAJ 
    input  [DATA_WIDTH-1:0] b_i,
    output [DATA_WIDTH-1:0] a_o, 
    output [DATA_WIDTH-1:0] b_o, 
    output [DATA_WIDTH-1:0] add_o
);

    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    reg [DATA_WIDTH-1:0] x;
    reg valid;
    
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
   
    assign a_o = a;
    assign b_o = b;  
       
    assign mul = a * b; 
    assign add_o = mul + x; //za visebitne signale ide * i + //da li treba x ili x_out?
    
 endmodule   
    
        
//    always @(posedge clk_i) begin
//        if(!reset_i) begin
//            valid <= 0;
//        end else if (en_a_i == 0 && en_b_i == 0) begin
//            valid <= 1;
//        end else begin
//            valid <= 0;
//        end
//    end
    
    
//    assign mul = (valid) ? a * b : 0;
//    assign add_o = (valid) ? mul + x : 0;

    //gde stoji rec wire

    
