`timescale 1ns/1ps

//------------------------------------------------------------------------------
// File        : tb_atm_controller.sv
// Author      : Kartik Malipatil / 1BM23EC117
// Created     : 2026-02-03
// Module      : tb_atm_controller
// Project     : SystemVerilog and Verification (23EC6PE2SV)
// Faculty     : Prof. Ajaykumar Devarapalli
//
// Description :
//   This testbench verifies the functionality of the
//   ATM Controller module. It generates a clock and reset,
//   applies multiple stimulus scenarios such as valid
//   transactions, invalid PIN entry, and insufficient
//   balance conditions to exercise all FSM states.
//
//   The testbench also generates a VCD dump file for
//   waveform analysis using EPWave/GTKWave, enabling
//   observation of internal signal transitions and
//   verification of correct cash dispensing behavior.
//
//------------------------------------------------------------------------------
module tb_atm_controller;

    // Signals
    reg clk;
    reg rst;
    reg card_inserted;
    reg pin_correct;
    reg balance_ok;
    wire dispense_cash;

    // DUT
    atm_controller dut (
        .clk(clk),
        .rst(rst),
        .card_inserted(card_inserted),
        .pin_correct(pin_correct),
        .balance_ok(balance_ok),
        .dispense_cash(dispense_cash)
    );

    // Clock (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // 🔹 VCD DUMP (CRITICAL FIX)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, tb_atm_controller);   // <-- IMPORTANT
    end

    // Test sequence
    initial begin
        rst = 1;
        card_inserted = 0;
        pin_correct = 0;
        balance_ok = 0;

        #20 rst = 0;

        // Valid transaction
        #10 card_inserted = 1;
        #10 card_inserted = 0;
        #10 pin_correct = 1;
        #10 balance_ok = 1;
        #20;

        // Invalid PIN
        pin_correct = 0;
        balance_ok = 0;
        #10 card_inserted = 1;
        #10 card_inserted = 0;
        #30;

        // Insufficient balance
        #10 card_inserted = 1;
        #10 card_inserted = 0;
        #10 pin_correct = 1;
        #20 balance_ok = 0;
        #30;

        // End simulation
        #50;
        $finish;
    end

endmodule
