//------------------------------------------------------------------------------
// File        : atm_controller.sv
// Author      : Kartik Malipatil / 1BM23EC117
// Created     : 2026-02-03
// Module      : atm_controller
// Project     : SystemVerilog and Verification (23EC6PE2SV)
// Faculty     : Prof. Ajaykumar Devarapalli
//
// Description :
//   This module implements an ATM Controller using a
//   Finite State Machine (FSM). The controller processes
//   user inputs such as card insertion, PIN verification,
//   and balance validation to control cash dispensing.
//
//   The FSM consists of four states: IDLE, CHECK_PIN,
//   CHECK_BAL, and DISPENSE. Cash is dispensed only when
//   both PIN and balance conditions are satisfied.
//   SystemVerilog assertions are included to ensure that
//   cash is dispensed only under valid conditions and that
//   the system returns to the IDLE state after dispensing.
//
//------------------------------------------------------------------------------
module atm_controller (
    input  logic clk,
    input  logic rst,
    input  logic card_inserted,
    input  logic pin_correct,
    input  logic balance_ok,
    output logic dispense_cash
);

    // State encoding
    typedef enum logic [1:0] {
        IDLE,
        CHECK_PIN,
        CHECK_BAL,
        DISPENSE
    } state_t;

    state_t current_state, next_state;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next-state logic
    always_comb begin
        next_state = current_state;
        dispense_cash = 1'b0;

        case (current_state)
            IDLE: begin
                if (card_inserted)
                    next_state = CHECK_PIN;
            end

            CHECK_PIN: begin
                if (pin_correct)
                    next_state = CHECK_BAL;
                else
                    next_state = IDLE;
            end

            CHECK_BAL: begin
                if (balance_ok)
                    next_state = DISPENSE;
                else
                    next_state = IDLE;
            end

            DISPENSE: begin
                dispense_cash = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // =============================
    // Assertions
    // =============================

    // 1. Cash dispensed ONLY if pin_correct AND balance_ok
    property cash_only_if_valid;
        @(posedge clk)
        dispense_cash |-> (pin_correct && balance_ok);
    endproperty

    assert property (cash_only_if_valid)
        else $error("ERROR: Cash dispensed without valid PIN or balance");

    // 2. Machine returns to IDLE after dispensing
    property return_to_idle;
        @(posedge clk)
        (current_state == DISPENSE) |=> (current_state == IDLE);
    endproperty

    assert property (return_to_idle)
        else $error("ERROR: ATM did not return to IDLE after dispensing");

endmodule
