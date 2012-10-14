/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns / 1ps

module test_final_round;

	// Inputs
	reg clk;
	reg [127:0] state_in;
	reg [127:0] key_in;
	reg [7:0] rcon;

	// Outputs
	wire [127:0] state_out;
    wire [31:0] s0, s1, s2, s3;

	// Instantiate the Unit Under Test (UUT)
	final_round uut (
		.clk(clk), 
		.state_in(state_in), 
		.key_in(key_in), 
		.state_out(state_out), 
		.rcon(rcon)
	);

    assign {s0, s1, s2, s3} = state_out;

	initial begin
		clk = 0;
		state_in = 0;
        key_in = 0;
        rcon = 0;

		#100;
        @ (negedge clk);
        state_in = {32'heb_40_f2_1e, 32'h59_2e_38_84, 32'h8b_a1_13_e7, 32'h1b_c3_42_d2};
		key_in = {32'hac_77_66_f3, 32'h19_fa_dc_21, 32'h28_d1_29_41, 32'h57_5c_00_6e};
		rcon = 8'h36;
        #10;
		state_in = 0;
        key_in = 0;
        rcon = 0;        
        #10;

        if(s0 != 32'h39_25_84_1d) begin $display("E"); $finish; end
        if(s1 != 32'h02_dc_09_fb) begin $display("E"); $finish; end
        if(s2 != 32'hdc_11_85_97) begin $display("E"); $finish; end
        if(s3 != 32'h19_6a_0b_32) begin $display("E"); $finish; end
        
        $display("Good.");
        $finish;
	end
    
    always #5 clk = ~clk;
endmodule

