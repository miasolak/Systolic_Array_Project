module fsm (
    input wire clk_i,
    input wire reset_i,
    output reg en_a_o,
    output reg en_b_o,
    output reg en_x_o
);

    localparam Idle    = 2'b00;
    localparam Load_AB = 2'b01;
    localparam Load_X  = 2'b10;
  //  localparam Wait    = 2'b11;

    reg [1:0] state, next_state;
    reg [1:0] counter;
    

    // Sekvencijalna logika
    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            state <= Idle;
            counter <= 0;
        end else begin
        
        if (state != next_state)      // ovo smisli jel moze drugacije nekako PITAAAJ
              counter <= 0;
        else
              counter <= counter + 1;
                
        state <= next_state;
             
        end
    end

    // Kombinaciona logika
    always @(*) begin
        case (state)
            Idle: next_state = Load_AB;
            Load_AB: begin
                if (counter == 2) // PROMENA: sad čekaš 0,1,2,3 (3 takta)
                    next_state = Load_X;
                else
                    next_state = Load_AB;
            end
            Load_X: begin
                if (counter == 2)
                    next_state = Load_AB;
                else
                    next_state = Load_X;
            end
            
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
