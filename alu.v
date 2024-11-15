module mem_op (
    input bit clk,
    input bit reset,
    input bit memwrite,  // 0 for load, 1 store
    input [2:0] funct3,
    input [31:0] rs1,
    output reg [31:0] rd,
    reg [32:0] mem[65536]  // 256bit (for 16 - 4096)
);

  wire [31:0] address;  // Effective memory address

  // Compute effective address
  assign address = rs1 + {{20{imm[11]}}, imm};  // Sign-extend immediate

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      rd <= 32'b0;
    end else if (memwrite) begin
      unique case (funct3)
        3'b000: mem[address] <= rs2[7:0];  // SB (Store Byte)
        3'b001: begin  // SH (Store Half-word)
          mem[address]   <= rs2[7:0];
          mem[address+1] <= rs2[15:8];
        end
        3'b010: begin  // SW (Store Word)
          mem[address]   <= rs2[7:0];
          mem[address+1] <= rs2[15:8];
          mem[address+2] <= rs2[23:16];
          mem[address+3] <= rs2[31:24];
        end
      endcase
    end else begin
      case (funct3)
        3'b000: rd <= {{24{mem[address][7]}}, mem[address]};  // LB (Load Byte, sign-extend)
        3'b001:
        rd <= {
          {16{mem[address+1][7]}}, mem[address+1], mem[address]
        };  // LH (Load Half, sign-extend)
        3'b010:
        rd <= {mem[address+3], mem[address+2], mem[address+1], mem[address]};  // LW (Load Word)
        3'b100: rd <= {24'b0, mem[address]};  // LBU (Load Byte, zero-extend)
        3'b101: rd <= {16'b0, mem[address+1], mem[address]};  // LHU (Load Half, zero-extend)
        default: rd <= 32'b0;  // Invalid funct3
      endcase
    end
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
  always @(posedge clk) begin
    case (funct3)
      3'b000: begin  // ADD / ADDI
        out <= alt ? (x - y) : (x + y);
      end
      3'b001: begin  // SLL
        out <= x << y[4:0];
      end
      3'b010: begin  // SLT
        out <= {31'b0, $signed(x) < $signed(y)};
      end
      3'b011: begin  // SLTU
        out <= {31'b0, x < y};
      end
      3'b100: begin  // BITWISE XOR
        out <= x ^ y;
      end
      3'b101: begin  // SRL
        out <= alt ? (x >>> y[4:0]) : (x >> y[4:0]);
      end
      3'b110: begin  // BITWISE OR
        out <= x | y;
      end
      3'b111: begin  // BITWISE AND
        out <= x & y;
      end
      default: ;
    endcase
  end
endmodule

function automatic [7:0] alu_fn;
  input [2:0] funct3;
  input [7:0] x;
  input [7:0] y;
  input bit alt;

  begin
    case (funct3)
      3'b000: begin  // ADD / ADDI
        alu = alt ? (x - y) : (x + y);
      end
      3'b001: begin  // SLL
        alu = x << y[4:0];
      end
      3'b010: begin  // SLT
        alu = {31'b0, $signed(x) < $signed(y)};
      end
      3'b011: begin  // SLTU
        alu = {31'b0, x < y};
      end
      3'b100: begin  // BITWISE XOR
        alu = x ^ y;
      end
      3'b101: begin  // SRL
        alu = alt ? (x >>> y[4:0]) : (x >> y[4:0]);
      end
      3'b110: begin  // BITWISE OR
        alu = x | y;
      end
      3'b111:  alu = x & y;  // BITWISE AND
      default: alu = 8'h0;
    endcase
  end
endfunction

