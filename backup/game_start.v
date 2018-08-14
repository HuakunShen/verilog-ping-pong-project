module game_start(
    input clk, resetn, enable,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] color_out,
    output reg done_signal
    );
    
    wire counter1_done, counter2_done;

    localparam  START = 6'd0,
                G1 = 6'd1,
                G2 = 6'd2,
				G3 = 6'd3,  
                G4 = 6'd4,          
				G5 = 6'd5,           
                G6 = 6'd6,
                G7 = 6'd7,
                G8 = 6'd8,
                G9 = 6'd9,
                F1 = 6'd10,
                F2 = 6'd11,
                O1 = 6'd12,
                O2 = 6'd13,
                O3 = 6'd14,
                O4 = 6'd15,
                O5 = 6'd16,
                O6 = 6'd17,
                O7 = 6'd18,
                O8 = 6'd19,
                FF = 6'd20,                
                DONE = 6'd21;

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
    timer_l t77384(clk, reset_done, 1'b1, 26'd1, hold);


    always @(*)
    begin: state_table
        case (current_state)
            START: next_state = enable ? G1 : START;
            G1: next_state = counter1_done ? G2 : G1;
            G2: next_state = counter2_done ? G3 : G2;
            G3: next_state = counter1_done ? G4 : G3;
            G4: next_state = counter2_done ? G5 : G4;
            G5: next_state = counter1_done ? G6 : G5;
            G6: next_state = counter2_done ? G7 : G6;
            G7: next_state = counter1_done ? G8 : G7;
            G8: next_state = counter2_done ? G9 : G8;
            G9: next_state = counter1_done ? F1 : G9;
            F1: next_state = counter2_done ? F2 : F1;
            F2: next_state = counter1_done ? O1 : F2;
            O1: next_state = counter2_done ? O2 : O1;            
            O2: next_state = counter1_done ? O3 : O2;
            O3: next_state = counter2_done ? O4 : O3;
            O4: next_state = counter1_done ? O5 : O4;
            O5: next_state = counter2_done ? O6 : O5;
            O6: next_state = counter1_done ? O7 : O6;
            O7: next_state = counter2_done ? O8 : O7;
            O8: next_state = counter1_done ? DONE : O8;
            DONE: next_state = hold ? START : DONE;
            default: next_state = START;                                       
        endcase
	end


    reg [5:0] width, height;
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
        color = 3'b00;
        width = 1'b0;
        height = 1'b0;    
        done_signal = 1'b0;    
		case (current_state)
			G1: begin
                reset1 = 1'b1;
                x_pos = 8'd61;
                y_pos= 7'd27;
                width = 6'd11;
                height = 6'd3;
                color = 3'b110;
            end
            G2: begin
                reset2 = 1'b1;
                x_pos = 8'd60;
                y_pos= 7'd30;                
                width = 6'd3;
                height = 6'd2;
                color = 3'b110;
            end
            G3: begin
                reset1 = 1'b1;
                x_pos = 8'd59; 
                y_pos = 7'd32;
                width = 6'd3;
                height = 6'd2;
                color = 3'b110;
            end
            G4: begin
                reset2 = 1'b1;
                x_pos = 8'd58; 
                y_pos = 7'd34;
                width = 6'd2;
                height = 6'd30;
                color = 3'b110;
            end
            G5: begin
                reset1 = 1'b1;
                x_pos = 8'd58; 
                y_pos = 7'd65;
                width = 6'd3;
                height = 6'd2;
                color = 3'b110;
            end
            G6: begin
                reset2 = 1'b1;
                x_pos = 8'd59; 
                y_pos = 7'd67;
                width = 6'd3;
                height = 6'd2;
                color = 3'b110;
            end
            G7: begin
                reset1 = 1'b1;
                x_pos = 8'd60; 
                y_pos = 7'd69;
                width = 6'd11;
                height = 6'd3;
                color = 3'b110;
            end
            G8: begin
                reset2 = 1'b1;
                x_pos = 8'd69; 
                y_pos = 7'd60;                
                width = 6'd3;
                height = 6'd9;
                color = 3'b110;
            end
            G9: begin
                reset1 = 1'b1;
                x_pos = 8'd67; 
                y_pos = 7'd57;                
                width = 6'd7;
                height = 6'd3;
                color = 3'b110;
            end
            F1: begin
                reset2 = 1'b1;
                x_pos = 8'd104; 
                y_pos = 7'd27;
                width = 6'd3;
                height = 6'd37;
                color = 3'b110;
            end
            F2: begin
                reset1 = 1'b1;
                x_pos = 8'd104;   
                y_pos = 7'd67;            
                width = 6'd3;
                height = 6'd5;
                color = 3'b110;
            end
            O1: begin
                reset2 = 1'b1;
                x_pos = 8'd83; 
                y_pos = 7'd27;
                width = 6'd14;
                height = 6'd3;
                color = 3'b110;
            end
            O2: begin
                reset1 = 1'b1;
                x_pos = 8'd81; 
                y_pos = 7'd30;
                width = 6'd3;
                height = 6'd5;
                color = 3'b110;
            end
            O3: begin
                reset2 = 1'b1;
                x_pos = 8'd80; 
                y_pos = 7'd35;
                width = 6'd3;
                height = 6'd29;
                color = 3'b110;
            end
            O4: begin
                reset1 = 1'b1;
                x_pos = 8'd81; 
                y_pos = 7'd64;
                width = 6'd3;
                height = 6'd5;
                color = 3'b110;
            end
            O5: begin
                reset2 = 1'b1;
                x_pos = 8'd83; 
                y_pos = 7'd69;                                
                width = 6'd14;
                height = 6'd3;
                color = 3'b110;
            end
            O6: begin
                reset1 = 1'b1;
                x_pos = 8'd97; 
                y_pos = 7'd64;
                width = 6'd3;
                height = 6'd5;
                color = 3'b110;
            end
            O7: begin
                reset2 = 1'b1;
                x_pos = 8'd98; 
                y_pos = 7'd35;
                width = 6'd3;
                height = 6'd29;
                color = 3'b110;
            end
            O8: begin
                reset1 = 1'b1;
                x_pos = 8'd97; 
                y_pos = 7'd30;
                width = 6'd3;
                height = 6'd5;
                color = 3'b110;
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
    assign color_out = 3'b110;

endmodule       