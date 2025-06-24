module fsm #(parameter M = 3, N = 3)(
    input wire clk_i,
    input wire reset_i,
    input wire ready_i,
    output reg en_a_o,
    output reg en_b_o,
    output reg en_x_o
);
    reg [3:0] max;
    reg [3:0] min;
    
    localparam Idle    = 2'b00;
    localparam Load_AB = 2'b01;
    localparam Wait    = 2'b11;
    localparam Load_X  = 2'b10;

    reg [1:0] state, next_state;
    reg [3:0] counter;
    

    // Sekvencijalna logika
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

    // Kombinaciona logika
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
            
            //ready A, ready B
            Load_AB: begin
                    if (counter == min - 1) begin
                        if (M == N)
                            next_state = Load_X;  // odmah ide u Load_X
                        else
                            next_state = Wait;    // ide u Wait ako treba
                    end else begin
                        next_state = Load_AB;     // još nije gotovo
                    end
            
            end     
            Wait: begin
                    if (counter == max - min - 1) // PROMENA: sad čekaš 0,1,2,3 (3 takta)
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
            //posle ovog ili u idle ili load ab (ready a, ready b)
            
            default: next_state = Idle;
        endcase
    end

    // Izlazna logika
    always @(*) begin           //pitaj sta sa ovom zvezdicom?? - oznacava sve ulazne signale koji se koriste u ovom bloku
        en_a_o = 0;
        en_b_o = 0;
        en_x_o = 0;

        case (state)
            Load_AB: begin
                en_a_o = 1;
                en_b_o = 1;             //OBAVEZNO OVDE VIDI ZNAKOVE - DA LI JE = ILI <= ???? 
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
                en_x_o = 1;             //odgovor: ovde je always bez posedge dakle kombinaciona dakle ide ovo =
            end
            default: begin
                en_a_o = 0;
                en_b_o = 0;
                en_x_o = 0;
            end
        endcase
    end

endmodule
