`ifndef PIPECORE_IF_SV
`define PIPECORE_IF_SV

interface pipecore_if;

logic done;
logic enable;
logic [255:0] midstate;
logic [2047:0] message;
logic [255:0] final_digest;

modport out (input enable, input midstate, input message, output done, output final_digest);
modport in (output midstate, output message, output enable, input done, input final_digest);

endinterface

`endif