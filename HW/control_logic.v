`timescale 1ns / 1ps

module control_logic #(
    parameter M = 3,
    parameter N = 3
)(
    input wire clk_i,
    input wire reset_i,
    input wire ready_i,
    output reg en_a_o,
    output reg en_b_o,
    output reg en_x_o
);
   
    //function for calculating min number of bits for counter
    function integer counter_bits;  
    input integer max, min, N;
    integer max_count, temp;
    begin
        max_count = min;
        if (max - min > max_count)
            max_count = max - min;
        if (N > max_count)
            max_count = N;
        
        counter_bits = 0;
        temp = max_count;
        while (temp > 0) begin
            counter_bits = counter_bits + 1;     //stavi clog2 !!!$clog
            temp = temp >> 1;
        end
              
    end
    endfunction
    
    //calling function from above
    localparam max_bits = counter_bits (
        (M > N) ? M : N,
        (M > N) ? N : M,
        N
    );
    
    // Internal parameters and state registers
    localparam Idle    = 2'b00;
    localparam Load_AB = 2'b01;
    localparam Wait    = 2'b11;
    localparam Load_X  = 2'b10;
    
    reg [1:0] state, next_state;
    reg [30:0] counter;
    reg [10:0] max;
    reg [10:0] min;
    reg [1:0] prev_state;
    reg [1:0] current_state;  // dodatni reg
 //   reg ctrl_reg;
     
    // State and counter update
    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            state <= Idle;
            counter <= 0;
       //     ctrl_reg <= 0;
        end else begin
        if (state != next_state)      
              counter <= 0;
        else
              counter <= counter + 1;
                
        state <= next_state;
        
             
        end
    end

    // Next state logic
    always @(*) begin
        if (M > N) begin
            max = M;
            min = N;
        end else begin
            max = N;
            min = M;
        end
        
        case (state)
        
            //Waiting for data to be ready
            Idle: if (ready_i == 1) begin
                      next_state = Load_AB;
                  end else begin
                      next_state = Idle;
            end 
            
            //Loading data
            Load_AB: begin
                if (counter == min - 1) begin
                    if (M == N)
                        next_state = Load_X;  
                    else
                        next_state = Wait;   
                    end else begin
                        next_state = Load_AB;   
                    end
            end     
            
            //Loads the remaining part of the larger matrix
            Wait: begin
                if (counter == max - min - 1) 
                    next_state = Load_X;
                else
                    next_state = Wait;
            end
            
            //Calculating for N cycles  
            Load_X: begin
                if (counter == N - 1)
                    if (ready_i == 1) 
                        next_state = Load_AB;
                    else                  
                        next_state = Idle;
                else
                    next_state = Load_X;
            end
            
            default: next_state = Idle;
        endcase
    end

    // Output logic
    always @(*) begin           
        en_a_o = 0;
        en_b_o = 0;
        en_x_o = 0;
    //    ctrl_o = ctrl_reg;
        
        case (state)
            Load_AB: begin
                en_a_o = 1;
                en_b_o = 1;            
            end
            
            Wait: begin
                if (M > N) begin
                    en_a_o = 1;
                    en_b_o = 0;
                end else begin
                    en_a_o = 0;
                    en_b_o = 1;
                end 
            end
            
            Load_X: begin
                en_x_o = 1;             
            end
            
            default: begin
                en_a_o = 0;
                en_b_o = 0;
                en_x_o = 0;
            end
        endcase
    end

endmodule
