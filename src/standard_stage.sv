`include "utils.sv"
`default_nettype none
`timescale 1us / 100 ns

module standard_stage # (parameter bit [31:0] k) (
    input logic [31:0] wi, 
    pipe_if.in prev_stage, 
    pipe_if.out next_stage
);
    function automatic logic [31:0] rotr32 (
        input logic [31:0] a,
        input logic [4:0] b
    );
        rotr32 = (a >> b) | (a << (32 - b));
    endfunction
    
    function automatic logic [31:0] sum0 (
        input logic [31:0] a
    );
        sum0 = rotr32(a,2) ^ rotr32(a,13) ^ rotr32(a,22);
    endfunction

    function automatic logic [31:0] sum1 (
        input logic [31:0] a
    );
        sum1 = rotr32(a,6) ^ rotr32(a,11) ^ rotr32(a,25);
    endfunction

    function automatic logic [31:0] ch (
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [31:0] c
    );
        ch = (a & b) ^ (~a & c);
    endfunction

    logic [31:0] csa0_sum;
    logic [31:0] csa0_carry;

    logic [31:0] csa1_sum;
    logic [31:0] csa1_carry;

    logic [31:0] csa2_sum;
    logic [31:0] csa2_carry;

    logic [31:0] s0, s1;
    logic [31:0] ch_e, maj_a;
    logic [31:0] t1, t2;

    assign s1   = sum1(prev_stage.data[159:128]);
    assign s0   = sum0(prev_stage.data[31:0]);
    assign ch_e = ch(prev_stage.data[159:128], prev_stage.data[191:160], prev_stage.data[223:192]);
    assign maj_a = maj(prev_stage.data[31:0], prev_stage.data[63:32], prev_stage.data[95:64]);

    always_comb begin
        csa(prev_stage.data[255:224], k, wi, csa0_carry, csa0_sum);
        csa(s1, ch_e, csa0_sum, csa1_carry, csa1_sum);
        csa(csa1_sum, (csa1_carry << 1), (csa0_carry << 1), csa2_carry, csa2_sum);

        assign t1 = csa2_sum + (csa2_carry << 1);
        assign t2 = s0 + maj_a;
    end

    always @ (posedge prev_stage.clk or negedge prev_stage.reset_n) begin
        if(~prev_stage.reset_n) begin

            next_stage.data <= '{default:0};
            next_stage.valid <= 1'b0;

        end else if (prev_stage.valid) begin
            next_stage.data[255:224] <= prev_stage.data[223:192]; // h=g
            next_stage.data[223:192] <= prev_stage.data[191:160]; // g=f
            next_stage.data[191:160] <= prev_stage.data[159:128]; // f=e
            next_stage.data[159:128] <= next_stage.data[127:96] + t1; // e = d + t1
            next_stage.data[127:96] <= prev_stage.data[95:64];    // d=c
            next_stage.data[95:64] <= prev_stage.data[63:32];     // c=b
            next_stage.data[63:32] <= prev_stage.data[31:0];      // b=a
            next_stage.data[31:0] <= t1 + t2;// a = t1 + t2
            next_stage.valid <= prev_stage.valid;
        end
    end

endmodule

