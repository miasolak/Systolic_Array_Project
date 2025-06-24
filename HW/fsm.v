module fsm #(
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
    
    // Internal parameters and state registers
    localparam Idle    = 2'b00;
    localparam Load_AB = 2'b01;
    localparam Wait    = 2'b11;
    localparam Load_X  = 2'b10;
    
    reg [1:0] state, next_state;
    reg [3:0] counter;
    reg [3:0] max;
    reg [3:0] min;

    

    // State and counter update
    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            state <= Idle;
            counter <= 0;
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
            Idle: if (ready_i == 1) begin
                      next_state = Load_AB;
                  end else begin
                      next_state = Idle;
            end 
            
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
            
            Wait: begin
                if (counter == max - min - 1) // Waiting to reach max(N, M)
                    next_state = Load_X;
                else
                    next_state = Wait;
            end
            
            Load_X: begin
                if (ready_i == 0) begin
                    next_state = Idle;
                end else                  
                    if (counter == N - 1)
                        next_state = Load_AB;
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
