`timescale 1ns/1ps
`include "pipecore_if.sv"
`include "utils.sv"

module standard_pipeline (
    input logic clk, reset_n,
    pipecore_if.out out_if
);
    
    pipe_if bus [64:0] (.*);

    assign bus[0].data = {h_init[31:0],h_init[63:32],h_init[95:64],h_init[127:96],h_init[159:128],h_init[191:160],h_init[223:192],h_init[255:224]};
    assign bus[0].valid = out_if.enable;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            standard_stage # (
                .k(k[((32*(i+1))-1):(32*i)])
            ) stdstage_i (
                .wi(out_if.message[((32*(i+1))-1):(32*i)]),
                .prev_stage(bus[i].in),
                .next_stage(bus[i+1].out)
            );
        end
    endgenerate

    always_ff @(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            out_if.done <= 1'b0;
            out_if.final_digest <= '{default:0};
        end else begin
            out_if.done <= bus[64].valid;
            out_if.final_digest <= bus[64].data;
        end
    end

endmodule
