// Samuel Sugimoto, Chen Xie
// EEC181A, W'16
// Group Name: Units
// Lab 3, sdram_master.v

module sdram_master(
	input clk,
	output reg read_n = 1,
	output reg write_n = 1,
	output reg chipselect,
	input waitrequest,
	output reg [31:0] address = 0,
	output reg [1:0] byteenable,
	input readdatavalid,
	input [15:0] readdata,
	output reg [15:0] writedata,
	input reset_n
	//input [0:0] ready,
	//output reg [0:0] done
	);
	
	reg [3:0] counter1 = 4'b0;  //Manages which value to compare
	reg [1:0] counter2 = 2'b0;
	reg [3:0] state1 = 4'b0;
	reg [3:0] state2 = 4'b0;
	reg [15:0] readin = 16'b0;
	reg [15:0] curr_min = 16'b0;
	reg [15:0] curr_max = 16'b0;
	reg [0:0] toggle = 1'b0;
	reg [0:0] dataready = 1'b0;
	reg [0:0] beginread = 1'b0;
	//reg [15:0] storage = 16'b0;

	//Begin code here
	always @ (posedge clk)
	begin
		// Main state machine for modifying data
		case(state1 [3:0])
			// Read in a value
			4'b0000:
			begin
				write_n <= 1;
				dataready <= 1'b0;
				read_n <= 0;
				address [15:0] <= counter1[3:0];
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				if(waitrequest == 0)
				begin
					//readin [15:0] <= readdata[15:0];
					beginread <= 1;
					counter2 [1:0] <= 2'b01;
					//read_n <= 1;
					//chipselect <= 0;
					//byteenable <= 0;
					state1 <= 4'b0001;
				end
			end
			// Read in a current maximum
			4'b0001:
			begin
				read_n <= 0;
				address [15:0] <= 1;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				if(waitrequest == 0)
				begin
					//curr_max [15:0] <= readdata[15:0];
					//read_n <= 1;
					//chipselect <= 0;
					//byteenable <= 0;
					counter2 [1:0] <= 2'b10;
					state1 <= 4'b0010;
				end
			end
			// Read in current minimum
			4'b0010:
			begin
				read_n <= 0;
				address [15:0] <= 2;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				if(waitrequest == 0)
				begin
					//curr_min [15:0] <= readdata[15:0];
					//read_n <= 1;
					//chipselect <= 0;
					//byteenable <= 0;
					counter2 [1:0] <=  2'b11;
					state1 <= 4'b0011;
				end
			end
			// Check values, determine what to do
			4'b0011:
			begin
				if(dataready)
				begin
					if(curr_min [15:0] > curr_max [15:0])
					begin
						read_n <= 1;
						write_n <= 0;
						state1 <= 4'b0100;
					end
					else if(readin [15:0] > curr_max [15:0])
					begin
						read_n <= 1;
						write_n <= 0;
						state1 <= 4'b0110;
					end
					else if(readin[15:0] < curr_min[15:0])
					begin
						read_n <= 1;
						write_n <= 0;
						state1 <= 4'b0111;
					end
					else
					begin
						if(counter1 [3:0] == 0)
						begin
							counter1 [3:0] <= 3;
						end
						else if(counter1 [3:0] == 9)
						begin
							counter1 [3:0] <= 0;
						end
						else
						begin
							counter1 [3:0] <= counter1 [3:0] + 1;
						end
						state1 <= 4'b0000;
					end
				end
			end
			// If minimum > maximum, max write
			4'b0100:
			begin
				write_n <= 0;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				address [15:0] <= 1;
				writedata [15:0] <= curr_min [15:0];
				if(waitrequest == 0)
				begin
					//write_n <= 1;
					//chipselect <= 0;
					//byteenable [1:0] <= 2'b00;
					state1 <= 4'b0101;
				end
			end
			// If minimum > maximum, min write
			4'b0101:
			begin
				write_n <= 0;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				address [15:0] <= 2;
				writedata [15:0] <= curr_max [15:0];
				if(waitrequest == 0)
				begin
					
					//write_n <= 1;
					//chipselect <= 0;
					//byteenable [1:0] <= 2'b00;
					state1 <= 4'b0000;
				end
			end
			//If readin > curr_max
			4'b0110:
			begin
				write_n <= 0;
				address [15:0] <= 1;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				writedata [15:0] <= readin [15:0];
				if(waitrequest == 0)
				begin
					//write_n <= 1;
					//chipselect <= 0;
					//byteenable [1:0] <= 2'b00;
					if(counter1 [3:0] == 0)
					begin
						counter1 [3:0] <= 3;
					end
					else if(counter1 [3:0] == 9)
					begin
						counter1 [3:0] <= 0;
					end
					else
					begin
						counter1 [3:0] <= counter1 [3:0] + 1;
					end
					state1 <= 4'b0000;
				end
			end
			//If readin < curr_min
			4'b0111:
			begin
				write_n <= 0;
				address [15:0] <= 2;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				writedata [15:0] <= readin [15:0];
				if(waitrequest == 0)
				begin
					//write_n <= 1;
					//chipselect <= 0;
					//byteenable [1:0] <= 2'b00;
					if(counter1 [3:0] == 0)
					begin
						counter1 [3:0] <= 3;
					end
					else if(counter1 [3:0] == 9)
					begin
						counter1 [3:0] <= 0;
					end
					else
					begin
						counter1 [3:0] <= counter1 [3:0] + 1;
					end
					state1 <= 4'b0000;
				end
			end
		endcase

		//Separate state machine for storing information from readdata
		case(state2 [3:0])
			//Read data in to readin
			4'b0000:
			begin
				if(beginread)
				begin
					if(readdatavalid && counter2 [1:0] > 0)
					begin
						readin[15:0] <= readdata[15:0];
						state2 <= 4'b0001;
					end
				end
			end

			4'b0001:
			begin
				if(readdatavalid && counter2 [1:0] > 1)
				begin
					curr_max [15:0] <= readdata[15:0];
					state2 <= 4'b0010;
				end
			end
			// Reads in data to curr_min
			4'b0010:
			begin
				if(readdatavalid && counter2 [1:0] > 2)
				begin
					curr_min [15:0] <= readdata[15:0];
					state2 <= 4'b0000;
					counter2 [1:0] <= 2'b00;
					beginread <= 1'b0;
					dataready <= 1'b1;
				end
			end
		endcase
	end

endmodule
