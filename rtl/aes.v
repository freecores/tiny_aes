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

module aes_128(clk, state, key, out);
    input          clk;
    input  [127:0] state, key;
    output [127:0] out;
    reg    [127:0] s0, k0;
    wire   [127:0] s1, k1, s2, k2, s3, k3, s4, k4, s5, k5,
                   s6, k6, s7, k7, s8, k8, s9, k9, s10;

    always @ (posedge clk)
      begin
        s0 <= state ^ key;
        k0 <= key;
      end
    assign out = s10;
    one_round
        r1 (clk, s0, k0, s1, k1, 8'h1),
        r2 (clk, s1, k1, s2, k2, 8'h2),
        r3 (clk, s2, k2, s3, k3, 8'h4),
        r4 (clk, s3, k3, s4, k4, 8'h8),
        r5 (clk, s4, k4, s5, k5, 8'h10),
        r6 (clk, s5, k5, s6, k6, 8'h20),
        r7 (clk, s6, k6, s7, k7, 8'h40),
        r8 (clk, s7, k7, s8, k8, 8'h80),
        r9 (clk, s8, k8, s9, k9, 8'h1b);
    final_round
        rf (clk, s9, k9, s10, 8'h36);
endmodule

module one_round(clk, state_in, key_in, state_out, key_out, rcon);
    input              clk;
    input      [127:0] state_in,  key_in;
    input      [7:0]   rcon;
    output reg [127:0] state_out, key_out;
    wire [31:0] s0,  s1,  s2,  s3,
                v0,  v1,  v2,  v3,
                z0,  z1,  z2,  z3,
                p00, p01, p02, p03,
                p10, p11, p12, p13,
                p20, p21, p22, p23,
                p30, p31, p32, p33,
                k0,  k1,  k2,  k3;
    reg  [31:0] k0a, k1a, k2a, k3a;
    wire [31:0] k0b, k1b, k2b, k3b, k4a;
    
    assign {k0, k1, k2, k3} = key_in;
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;
    always @ (posedge clk)
        {k0a, k1a, k2a, k3a} <= {v0, v1, v2, v3};
    S4
        S4_0 (clk, {k3[23:0], k3[31:24]}, k4a);
    assign k0b = k0a ^ k4a;
    assign k1b = k1a ^ k4a;
    assign k2b = k2a ^ k4a;
    assign k3b = k3a ^ k4a;
    always @ (posedge clk)
        key_out <= {k0b, k1b, k2b, k3b};
    
    assign {s0, s1, s2, s3} = state_in;
    table_lookup
        t0 (clk, s0, p00, p01, p02, p03),
        t1 (clk, s1, p10, p11, p12, p13),
        t2 (clk, s2, p20, p21, p22, p23),
        t3 (clk, s3, p30, p31, p32, p33);
    assign z0 = p00 ^ p11 ^ p22 ^ p33 ^ k0b;
    assign z1 = p03 ^ p10 ^ p21 ^ p32 ^ k1b;
    assign z2 = p02 ^ p13 ^ p20 ^ p31 ^ k2b;
    assign z3 = p01 ^ p12 ^ p23 ^ p30 ^ k3b;
    always @ (posedge clk)
        state_out <= {z0, z1, z2, z3};
endmodule

module final_round(clk, state_in, key_in, state_out, rcon);
    input              clk;
    input      [127:0] state_in,  key_in;
    input      [7:0]   rcon;
    output reg [127:0] state_out;
    wire [31:0] s0,  s1,  s2,  s3,
                v0,  v1,  v2,  v3,
                z0,  z1,  z2,  z3,
                k0,  k1,  k2,  k3;
    reg  [31:0] k0a, k1a, k2a, k3a;
    wire [31:0] k0b, k1b, k2b, k3b, k4a;
    wire [7:0]  p00, p01, p02, p03,
                p10, p11, p12, p13,
                p20, p21, p22, p23,
                p30, p31, p32, p33;
    
    assign {k0, k1, k2, k3} = key_in;
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;
    always @ (posedge clk)
        {k0a, k1a, k2a, k3a} <= {v0, v1, v2, v3};
    S4
        S4_0 (clk, {k3[23:0], k3[31:24]}, k4a);
    assign k0b = k0a ^ k4a;
    assign k1b = k1a ^ k4a;
    assign k2b = k2a ^ k4a;
    assign k3b = k3a ^ k4a;
    
    assign {s0, s1, s2, s3} = state_in;
    S4
        S4_1 (clk, s0, {p00, p01, p02, p03}),
        S4_2 (clk, s1, {p10, p11, p12, p13}),
        S4_3 (clk, s2, {p20, p21, p22, p23}),
        S4_4 (clk, s3, {p30, p31, p32, p33});
    assign z0 = {p00, p11, p22, p33} ^ k0b;
    assign z1 = {p10, p21, p32, p03} ^ k1b;
    assign z2 = {p20, p31, p02, p13} ^ k2b;
    assign z3 = {p30, p01, p12, p23} ^ k3b;
    always @ (posedge clk)
        state_out <= {z0, z1, z2, z3};
endmodule
