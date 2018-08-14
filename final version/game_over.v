module game_over(
    input clk, resetn, winner, enable,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] color_out,
    output reg done_signal
    );


    
    wire counter1_done, counter2_done;

    localparam  START = 5'd0,
                P1 = 5'd1,
                P2 = 5'd2,
				P3 = 5'd3,  
                P4 = 5'd4,          
				S1 = 5'd5,           
                S2 = 5'd6,
                W1 = 5'd7,
                W2 = 5'd8,
                W3 = 5'd9,
                W4 = 5'd10,
                W5 = 5'd11,
                I1 = 5'd12,
                I2 = 5'd13,
                N1 = 5'd14,
                N2 = 5'd15,
                N3 = 5'd16,
                N4 = 5'd17,
                N5 = 5'd18,
                DONE = 5'd19;


    reg [4:0] current_state, next_state;
    always @(posedge clk) begin
        if (!resetn)
            current_state = START;
		else if (enable)
			current_state <= next_state;
	end

    // wire hold1, hold2;
    reg reset1, reset2;
    reg reset_done;
    wire hold;
    timer_l t77384(clk, reset_done, 1'b1, 26'd2, hold);
   






    always @(*)
    begin: state_table
        case (current_state)
            START: next_state = enable ? P1 : START;
            P1: next_state = counter1_done ? P2 : P1;
            P2: next_state = counter2_done ? P3 : P2;
            P3: next_state = counter1_done ? P4 : P3;
            P4: next_state = counter2_done ? S1 : P4;
            S1: next_state = counter1_done ? S2 : S1;
            S2: next_state = counter2_done ? W1 : S2;
            W1: next_state = counter1_done ? W2 : W1;
            W2: next_state = counter2_done ? W3 : W2;
            W3: next_state = counter1_done ? W4 : W3;
            W4: next_state = counter2_done ? W5 : W4;
            W5: next_state = counter1_done ? I1 : W5;
            I1: next_state = counter2_done ? I2 : I1;            
            I2: next_state = counter1_done ? N1 : I2;
            N1: next_state = counter2_done ? N2 : N1;
            N2: next_state = counter1_done ? N3 : N2;
            N3: next_state = counter2_done ? N4 : N3;
            N4: next_state = counter1_done ? N5 : N4;
            N5: next_state = counter2_done ? DONE : N5;     
            DONE: next_state = hold ? START : DONE;
            default: next_state = START;                                       
        endcase
	end


    reg [4:0] width, height;
    reg [7:0] x_pos;
    reg [6:0] y_pos;
    reg [2:0] color;
	always @(*)
	begin
        reset_done = 1'b0;
        reset1 = 1'b0;
        reset2 = 1'b0;
        x_pos = 1'b0;
        y_pos = 1'b0;
        color = 3'b000;
        width = 1'b0;
        height = 1'b0;    
        done_signal = 1'b0;    
		case (current_state)
			P1: begin
                reset1 = 1'b1;
                x_pos = 8'd12;
                y_pos= 7'd36;
                width = 5'd2;
                height = 5'd30;
                color = 3'b010;
            end
            P2: begin
                reset2 = 1'b1;
                x_pos = 8'd20;
                y_pos= 7'd36;                
                width = 5'd2;
                height = 5'd15;
                color = 3'b010;
            end
            P3: begin
                reset1 = 1'b1;
                x_pos = 8'd14; 
                y_pos = 7'd36;
                width = 5'd6;
                height = 5'd3;
                color = 3'b010;
            end
            P4: begin
                reset2 = 1'b1;
                x_pos = 8'd14; 
                y_pos = 7'd48;
                width = 5'd6;
                height = 5'd3;
                color = 3'b010;
            end
            S1: begin
                reset1 = 1'b1;
                x_pos = 8'd27; 
                y_pos = 7'd36;
                width = 5'd2;
                height = 5'd30;
                color = 3'b010;
            end
            S2: begin
                reset2 = 1'b1;
                x_pos = 8'd31; 
                y_pos = 7'd36;
                width = 5'd2;
                height = 5'd30;
                color = winner ? 3'b000 : 3'b010;
            end
            W1: begin
                reset1 = 1'b1;
                x_pos = 8'd113; 
                y_pos = 7'd38;
                width = 5'd3;
                height = 5'd14;
                color = 3'b100;
            end
            W2: begin
                reset2 = 1'b1;
                x_pos = 8'd116; 
                y_pos = 7'd48;                
                width = 5'd3;
                height = 5'd18;
                color = 3'b100;
            end
            W3: begin
                reset1 = 1'b1;
                x_pos = 8'd118; 
                y_pos = 7'd43;                
                width = 5'd4;
                height = 5'd7;
                color = 3'b100;
            end
            W4: begin
                reset2 = 1'b1;
                x_pos = 8'd121; 
                y_pos = 7'd48;
                width = 5'd3;
                height = 5'd18;
                color = 3'b100;
            end
            W5: begin
                reset1 = 1'b1;
                x_pos = 8'd124;   
                y_pos = 7'd38;            
                width = 5'd3;
                height = 5'd14;
                color = 3'b100;
            end
            I1: begin
                reset2 = 1'b1;
                x_pos = 8'd132; 
                y_pos = 7'd38;
                width = 5'd3;
                height = 5'd5;
                color = 3'b100;
            end
            I2: begin
                reset1 = 1'b1;
                x_pos = 8'd132; 
                y_pos = 7'd45;
                width = 5'd3;
                height = 5'd22;
                color = 3'b100;
            end
            N1: begin
                reset2 = 1'b1;
                x_pos = 8'd140; 
                y_pos = 7'd38;
                width = 5'd3;
                height = 5'd29;
                color = 3'b100;
            end
            N2: begin
                reset1 = 1'b1;
                x_pos = 8'd143; 
                y_pos = 7'd38;
                width = 5'd2;
                height = 5'd9;
                color = 3'b100;
            end
            N3: begin
                reset2 = 1'b1;
                x_pos = 8'd145; 
                y_pos = 7'd45;                                
                width = 5'd2;
                height = 5'd12;
                color = 3'b100;
            end
            N4: begin
                reset1 = 1'b1;
                x_pos = 8'd147; 
                y_pos = 7'd55;
                width = 5'd2;
                height = 5'd6;
                color = 3'b100;
            end
            N5: begin
                reset2 = 1'b1;
                x_pos = 8'd149; 
                y_pos = 7'd38;
                width = 5'd3;
                height = 5'd29;
                color = 3'b100;
            end
            DONE: begin
                done_signal = 1'b1;
                reset_done = 1'b1;
            end
		endcase
	end
    
    reg [9:0] counter2;
	always @(posedge clk) begin
		if (!reset2)
			counter2 <= 10'd0;
		else begin
            if (counter2 == 10'd1023)
			    counter2 <= 10'd0;
		    else
			    counter2 <= counter2 + 1'b1;
        end
	end
    assign counter2_done = (counter2 == 10'd1023);



    reg [9:0] counter1;
	always @(posedge clk) begin
		if (!reset1)
			counter1 <= 10'd0;
		else begin
            if (counter1 == 10'd1023)
			    counter1 <= 10'd0;
		    else
			    counter1 <= counter1 + 1'b1;
        end
	end
    assign counter1_done = (counter1 == 10'd1023);


    reg [9:0] counter;
    always @(*) begin
        if (counter1 > counter2)
            counter <= counter1;
        else
            counter <= counter2;
    end




    wire [4:0] x_offset, y_offset;
    assign x_offset = (counter[4:0] > width) ? width : counter[4:0];
    assign y_offset = (counter[9:5] > height) ? height : counter[9:5];
    assign x_out = x_pos + x_offset;
    assign y_out = y_pos + y_offset;
    assign color_out = color;

endmodule       