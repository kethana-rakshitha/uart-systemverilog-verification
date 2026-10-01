# UART Transmitter and Receiver Design and Verification using SystemVerilog

## Overview

This project implements a UART (Universal Asynchronous Receiver/Transmitter) communication system using SystemVerilog.

The project includes both a UART Transmitter (TX) and UART Receiver (RX). The transmitter converts 8-bit parallel data into a serial UART data stream, while the receiver reconstructs the serial data back into an 8-bit parallel value.

A SystemVerilog-based verification environment is developed to generate randomized data transactions, drive them to the UART transmitter, monitor the transmitted data, compare the actual data with the expected data using a scoreboard, and verify the design using assertions.

The verification environment uses SystemVerilog classes, mailboxes, randomized transactions, a driver, monitor, scoreboard, and environment.

---

## UART Communication

The UART communication frame consists of:

```text
        START       DATA BITS             STOP
          |       8-bit LSB First           |
          v                                 v
    ____                                      ____
        |__|__|__|__|__|__|__|__|__|__________|
          0    D0 D1 D2 D3 D4 D5 D6 D7     1
