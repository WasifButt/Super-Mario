module timer (HEX0, HEX1, HEX2, HEX3, CLOCK_50, timer_enable);
	input CLOCK_50;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	reg [1:0] Sel;
	wire [3:0] seconds, seconds2, minutes, minutes2;
	wire enable;
	wire [25:0] counter;
	input timer_enable;
	
	wire  [25:0] upperBound;
	assign upperBound = 26'b010111110101111000001111111;
	
	rateDividerForTime r(CLOCK_50, upperBound, enable,counter);
	fourbitcounter c(enable, timer_enable, CLOCK_50, seconds, seconds2, minutes, minutes2);
	

	hexDisplay H0(seconds[3:0], HEX0);
	hexDisplay H1(seconds2[3:0], HEX1);
	hexDisplay H2(minutes[3:0], HEX2);
	hexDisplay H3(minutes2[3:0], HEX3);


endmodule

module rateDividerForTime(input clock, input [25:0] upperBound, output reg enable, output reg [25:0] counter);
	always @(posedge clock)
	begin
		if (counter === 26'bx)
		begin
			counter <= 26'b0;
		end 
		else if (counter == upperBound)
		begin
			enable= 1'b1;
			counter <= 26'b0;
		end
		else
		begin
			enable = 1'b0;
			counter <= counter + 1 ;
		end
	end
		

endmodule 

module fourbitcounter(input enable, input timer_enable, clock, output reg [3:0] seconds, output reg [3:0] seconds2, output reg [3:0] minutes, output reg [3:0] minutes2);
	
	initial minutes2 = 0;
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if ((enable == 1'b1) && (timer_enable == 1'b1)) 
		begin
			seconds <= seconds + 1;
			if ((seconds % 9) == 0 && (seconds != 0)) begin
				seconds <= 0 ; 
				seconds2 <= seconds2 + 1;
			end
			if ((seconds2 == 5) && (seconds == 9)) begin
				seconds2 <= 0;
				seconds <= 0;
				minutes <= minutes + 1;
			end
			if (((minutes % 9) == 0) && (minutes != 0) && (seconds2 == 5) && (seconds == 9)) begin
				seconds <= 0;
				seconds2 <= 0;
				minutes <= 0;
				minutes2 <= minutes2 + 1;
			end	
		end
		else if (timer_enable == 1'b0) begin
			seconds <= 0; 
			seconds2 <= 0;
			minutes <= 0;
			minutes2 <= 0;
		end
			
	end

endmodule


module hexDisplay(input [3:0] SW, output [6:0] HEX0);
	reg c0,c1,c2,c3;
	always @(*)
		begin
			c3=SW[3];
			c2=SW[2];
			c1=SW[1];
			c0=SW[0];
		end
	
	assign HEX0[0]=~((c3|c2|c1|~c0)&(c3|~c2|c1|c0)&(~c3|c2|~c1|~c0)&(~c3|~c2|c1|~c0));
	assign HEX0[1]=~((c3|~c2|c1|~c0)& (c3|~c2|~c1|c0)&(~c3|c2|~c1|~c0)&(~c3|~c2|c1|c0)&(~c3|~c2|~c1|c0)& (~c3|~c2|~c1|~c0));
	assign HEX0[2]=~((c3|c2|~c1|c0)&(~c3|~c2|c1|c0)&(~c3|~c2|~c1|c0)&(~c3|~c2|~c1|~c0));
	assign HEX0[3]=~((c3|c2|c1|~c0)&(c3|~c2|c1|c0)&(c3|~c2|~c1|~c0)&(~c3|c2|~c1|c0)&(~c3|~c2|~c1|~c0)); 
	assign HEX0[4]=~((c3|c2|c1|~c0)&(c3|c2|~c1|~c0)&(c3|~c2|c1|c0)&(c3|~c2|c1|~c0)&(c3|~c2|~c1|~c0)&(~c3|c2|c1|~c0));
	assign HEX0[5]=~((c3|c2|c1|~c0)&(c3|c2|~c1|c0)&(c3|c2|~c1|~c0)&(c3|~c2|~c1|~c0)&(~c3|~c2|c1|~c0));
	assign HEX0[6]=~((c3|c2|c1|c0)&(c3|c2|c1|~c0)&(c3|~c2|~c1|~c0)& (~c3|~c2|c1|c0));
endmodule
