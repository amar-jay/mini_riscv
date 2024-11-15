// this i an instruction decoder
// we are using 32 bit instruction decoder

// 0 - Unknown type
// 1 - R type
// 2 - I type
// 3 - S type
// 4 - B type
// 5 - U type
// 6 - J type
module instruction_decoder (
    in [31:0] instruction,
    out [2:0] _type,
    out [6:0] opcode,
    out [3:0] rd,  // return variable address
    out [2:0] funct3,
    out [4:0] rs1,  // address of first variable
    out [4:0] rs2,
    out [6:0] funct7
);

  reg [7:0] mem[65536];  // 64bit memory
  always @(instruction) begin
    opcode = instruction[6:0];
    case (opcode)
      6'b0110011: begin
        _type = 3'b001;  // R
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        func7 = instruction[31:25];
        alu(clk, funct3, rs1, rs2, func7 == 6'h20, mem[rd]);
      end

      6'b0010011: begin
        _type = 3'b010;  // I
        // immidiate is different from R type bcs immediate is `rs2` value
        // already encoded in the instruction and not fetched from memory
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        imm = instruction[31:24];  // rs2 value
        alt = (funct3 == 3'h5 & imm[5:11] == 6'h20);
        alu(clk, funct3, rs1, imm, alt, mem[rd]);
      end

      6'b0000011: begin
        _type = 3'b010;  // I
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        imm = instruction[31:24];
      end

      6'b0100011: begin
        _type = 3'b011;  // S
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        // load values from memory
        rd = $signed(mem[rs1+imm][0:7]);  // load byte
        rd = $signed(mem[rs1+imm][0:15]);  // load half
        rd = mem[rs1+imm][0:31];  // load word
        rd = $unsigned(mem[rs1+imm][0:7]);  // load byte unsigned
        rd = $unsigned(mem[rs1+imm][0:15]);  // load half unsigned
      end

      7'b1100011: begin
        _type = 3'b100;  // B
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
      end

      7'b1101111: begin
        _type = 3'b101;  // J - jalr / jalr
        rd = instruction[11:7];
      end

      6'b0110111: begin
        _type = 3'b110;  // U
        rd = instruction[11:7];
      end

      7'b1110011: begin
        _type = 3'b111;  // environmenral call break
      end
      default: begin
        _type = 3'b000;
      end
    endcase

  end

endmodule
module alu (
    input clk,
    input [2:0] funct3,
    input [31:0] x,
    input [31:0] y,
    input alt,
    output reg [31:0] out
);
endmodule
