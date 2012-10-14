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

module test_one_round;

	// Inputs
	reg clk;
	reg [127:0] state_in;
	reg [127:0] key_in;
	reg [7:0] rcon;

	// Outputs
	wire [127:0] state_out;
	wire [127:0] key_out;
    wire [31:0] k0, k1, k2, k3, s0, s1, s2, s3;

	// Instantiate the Unit Under Test (UUT)
	one_round uut (
		.clk(clk), 
		.state_in(state_in), 
		.key_in(key_in), 
		.state_out(state_out), 
		.key_out(key_out), 
		.rcon(rcon)
	);

    assign {k0, k1, k2, k3} = key_out;
    assign {s0, s1, s2, s3} = state_out;

	initial begin
		clk = 0;
		state_in = 0;
        key_in = 0;
        rcon = 0;

		#100;
        @ (negedge clk);
        state_in = {32'h19_3d_e3_be, 32'ha0_f4_e2_2b, 32'h9a_c6_8d_2a, 32'he9_f8_48_08};
		key_in = {32'h2b_7e_15_16, 32'h28_ae_d2_a6, 32'hab_f7_15_88, 32'h09_cf_4f_3c};
		rcon = 1;
        #10;
		state_in = 0;
        key_in = 0;
        rcon = 0;        
        #10;
        if(k0 != 32'ha0_fa_fe_17) begin $display("E"); $finish; end
        if(k1 != 32'h88_54_2c_b1) begin $display("E"); $finish; end
        if(k2 != 32'h23_a3_39_39) begin $display("E"); $finish; end
        if(k3 != 32'h2a_6c_76_05) begin $display("E"); $finish; end
        
        if(s0 != 32'ha4_9c_7f_f2) begin $display("E"); $finish; end
        if(s1 != 32'h68_9f_35_2b) begin $display("E"); $finish; end
        if(s2 != 32'h6b_5b_ea_43) begin $display("E"); $finish; end
        if(s3 != 32'h02_6a_50_49) begin $display("E"); $finish; end
        
        $display("Good.");
        $finish;
	end
    
    always #5 clk = ~clk;
endmodule

