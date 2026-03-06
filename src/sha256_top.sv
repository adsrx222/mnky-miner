`timescale 1ns/1ps
`include "message_if.sv"
`include "std_pipeline/pipecore_if.sv"
`include "communications/uart_if.sv"
`include "utils.sv"

module sha256_top(
    input  logic clk,
    input  logic reset_n,
    input  logic uart_rx,
    output logic uart_tx
);

    // Input signals
    logic [255:0] midstate;
    logic [31:0]  target;
    logic [31:0]  merkle_root;
    logic [95:0]  data96;

    // Nonces
    logic [31:0] nonce0, nonce1, nonce2, nonce3;

    // Individual message interfaces
    message_if message0(.reset_n(reset_n));
    message_if message1(.reset_n(reset_n));
    message_if message2(.reset_n(reset_n));
    message_if message3(.reset_n(reset_n));

    // Individual pipeline interfaces
    pipecore_if pipe0();
    pipecore_if pipe1();
    pipecore_if pipe2();
    pipecore_if pipe3();

    // Connect messages
    assign message0.block = {midstate, merkle_root, data96[63:32], nonce0};
    assign message1.block = {midstate, merkle_root, data96[63:32], nonce1};
    assign message2.block = {midstate, merkle_root, data96[63:32], nonce2};
    assign message3.block = {midstate, merkle_root, data96[63:32], nonce3};

    // Message schedulers
    message_scheduler ms0(.clk(clk), .reset_n(reset_n), .message_in(message0.in));
    message_scheduler ms1(.clk(clk), .reset_n(reset_n), .message_in(message1.in));
    message_scheduler ms2(.clk(clk), .reset_n(reset_n), .message_in(message2.in));
    message_scheduler ms3(.clk(clk), .reset_n(reset_n), .message_in(message3.in));

    // Pipelines
    standard_pipeline sp0(.clk(clk), .reset_n(reset_n), .out_if(pipe0.out));
    standard_pipeline sp1(.clk(clk), .reset_n(reset_n), .out_if(pipe1.out));
    standard_pipeline sp2(.clk(clk), .reset_n(reset_n), .out_if(pipe2.out));
    standard_pipeline sp3(.clk(clk), .reset_n(reset_n), .out_if(pipe3.out));

    // Nonce increment logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nonce0 <= 0; nonce1 <= 1; nonce2 <= 2; nonce3 <= 3;
        end else begin
            if (pipe0.done && pipe0.final_digest >= {224'b0, target}) nonce0 <= nonce0 + 4;
            if (pipe1.done && pipe1.final_digest >= {224'b0, target}) nonce1 <= nonce1 + 4;
            if (pipe2.done && pipe2.final_digest >= {224'b0, target}) nonce2 <= nonce2 + 4;
            if (pipe3.done && pipe3.final_digest >= {224'b0, target}) nonce3 <= nonce3 + 4;
        end
    end

endmodule
