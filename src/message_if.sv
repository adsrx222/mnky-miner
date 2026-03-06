`ifndef MESSAGE_IF_SV
`define MESSAGE_IF_SV

/* verilator lint_off UNUSEDSIGNAL */
interface message_if (input logic reset_n);
    logic [511:0] block;
    logic [2047:0] schedule;

    modport in  (input block, output schedule);
    modport out  (input schedule, output block);
endinterface
/* verilator lint_on UNUSEDSIGNAL */

`endif

