`ifndef PIPE_IF_SV
`define PIPE_IF_SV


interface pipe_if(input logic clk, input logic reset_n);
    logic [255:0] data;
    logic valid;

    modport in  (input clk, input reset_n, input data, input valid);
    modport out (input clk, input reset_n, output data, output valid);
endinterface

`endif
