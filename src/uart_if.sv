`ifndef UART_IF_SV
`define UART_IF_SV
`default_nettype none

interface uart_if(input bit clk);

    logic tx;
    logic rx;

    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;

    logic [7:0] rx_data;
    logic       rx_done;

endinterface

`endif
