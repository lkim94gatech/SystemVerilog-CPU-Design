import CORE_PKG::*;

module LSU (
  // General Inputs
  input logic clock,
  input logic reset,
  input logic data_gnt_i,

  // Inputs from decode
  input logic lsu_en_ip,                      // enable the LSU because it is a memory operation
  input load_store_func_code lsu_operator_ip, 

  // Input from ALU
  input logic alu_valid_ip,
  input logic [31:0] mem_addr_ip,             // address to access in mem for read/write

  // Input data from DRAM after load
  input logic [31:0] mem_data_ip,

  // Output to Decode
  output logic data_req_op,                  // validity of data address request
  output logic [31:0] load_mem_data_op,      // data from load to send to decode 
  output logic invalid_address               // flag to indicate an invalid address
);

  logic valid_mem_operation;
  assign valid_mem_operation = data_gnt_i & lsu_en_ip & alu_valid_ip;

  always @(*) begin
    data_req_op = 1'b0;
    load_mem_data_op = 32'hz;
    invalid_address = 1'b0;

    if (valid_mem_operation) begin
      data_req_op = 1'b1;
      case (lsu_operator_ip)
        LW: begin
          /**
          * Check if the address sent to memory is valid for load words
          * 1. Check if the address is within a valid range for data memory.
          * 2. If the address is invalid, set a flag or signal to inform the processor.
          */
          if (mem_addr_ip[1:0] == 2'b00) begin
            load_mem_data_op = mem_data_ip;
          end else begin
            data_req_op = 1'b0;
          end
        end

        SW: begin
          /**
          * Check if the address sent to memory is valid for store words
          * 1. Check if the address is within a valid range for data memory.
          * 2. If the address is invalid, set a flag or signal to inform the processor.
          */
          if (mem_addr_ip[1:0] != 2'b00) begin
            data_req_op = 1'b0;
          end
        end
      endcase
    end
  end

endmodule
