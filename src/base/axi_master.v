/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

OUTFILE PREFIX.v

INCLUDE def_axi_master.txt


//////////////////////////////////////
//
// General:
//   The AXI master has an internal master per ID. 
//   These internal masters work simultaniously and an interconnect matrix connets them. 
// 
//
// I/F :
//   idle - all internal masters emptied their command FIFOs
//   scrbrd_empty - all scoreboard checks have been completed (for random testing)
//
//
// Tasks:
//
// enable(input master_num)
//   Description: Enables master
//   Parameters: master_num - number of internal master
//
// enable_all()  
//   Description: Enables all masters
//
// write_single(input master_num, input addr, input wdata)
//   Description: write a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//           addr  - address
//           wdata - write data
// 
// read_single(input master_num, input addr, output rdata)
//   Description: read a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//               addr  - address
//               rdata - return read data
//
// insert_wr_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rd_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI read burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_wr_data(input master_num, input wdata)
//   Description: add a single data to data FIFO (to be used in write bursts)
//   Parameters: master_num - number of internal master
//               wdata - write data
//  
// insert_wr_incr_data(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO will use incremental data (no need to use insert_wr_data)
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rand_chk(input master_num, input burst_num)
//   Description: add multiple commands to command FIFO. Each command writes incremental data to a random address, reads the data back and checks the data. Useful for random testing.
//   Parameters: master_num - number of internal master
//               burst_num - total number of bursts to check
//  

//  
//  Parameters:
//  
//    For random testing: (changing these values automatically update interanl masters)
//      len_min  - minimum burst LEN (length)
//      len_max  - maximum burst LEN (length)
//      size_min - minimum burst SIZE (length)
//      size_max - maximum burst SIZE (length)
//      addr_min - minimum address (in bytes)
//      addr_max - maximum address (in bytes)
//  
//////////////////////////////////////

  
ITER IX ID_NUM
module PREFIX(PORTS);

   input 			       clk;
   input                               reset;
   
   port                  	       GROUP_STUB_AXI;

   output                              idle;
   output                              scrbrd_empty;
   
   
   //random parameters
   integer                             GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND.DEFAULT;
   
   wire                                GROUP_STUB_AXI_IX;
   wire                                idle_IX;
   wire                                scrbrd_empty_IX;


   always @(*)
     begin
        #FFD;
        PREFIX_singleIX.GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND;
     end
   
   assign                              idle = CONCAT(idle_IX &);
   assign                              scrbrd_empty = CONCAT(scrbrd_empty_IX &);
   
   
   CREATE axi_master_single.v

     LOOP IX ID_NUM
   PREFIX_single #(IX, IDIX_VAL, CMD_DEPTH)
   PREFIX_singleIX(
                   .clk(clk),
                   .reset(reset),
                   .GROUP_STUB_AXI(GROUP_STUB_AXI_IX),
                   .idle(idle_IX),
                   .scrbrd_empty(scrbrd_empty_IX)
                   );
   ENDLOOP IX

     IFDEF TRUE(ID_NUM==1)
   
   assign GROUP_STUB_AXI.OUT = GROUP_STUB_AXI_0.OUT;
   assign GROUP_STUB_AXI_0.IN = GROUP_STUB_AXI.IN;
   
     ELSE TRUE(ID_NUM==1)

   CREATE ic.v DEFCMD(SWAP.GLOBAL PARENT PREFIX) DEFCMD(SWAP.GLOBAL MASTER_NUM ID_NUM) DEFCMD(SWAP.GLOBAL CONST(ID_BITS) ID_BITS) DEFCMD(SWAP.GLOBAL CONST(CMD_DEPTH) CMD_DEPTH) DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS) DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS)
   LOOP IX ID_NUM
     STOMP NEWLINE
     DEFCMD(LOOP.GLOBAL MIX_IDX 1)
     STOMP NEWLINE 
     DEFCMD(SWAP.GLOBAL ID_MIX_ID0 IDIX_VAL)
   ENDLOOP IX

    PREFIX_ic PREFIX_ic(
                       .clk(clk),
                       .reset(reset),
                       .MIX_GROUP_STUB_AXI(GROUP_STUB_AXI_IX),
                       .S0_GROUP_STUB_AXI(GROUP_STUB_AXI),
                       STOMP ,
      
      );

     ENDIF TRUE(ID_NUM==1)


   
   task check_master_num;
      input [24*8-1:0] task_name;
      input [31:0] master_num;
      begin
         if (master_num >= ID_NUM)
           begin
              $display("FATAL ERROR: task %0s called for master %0d that does not exist.\tTime: %0d ns.", task_name, master_num, $time);
           end
      end
   endtask
   
   task enable;
      input [31:0] master_num;
      begin
         check_master_num("enable", master_num);
         case (master_num)
           IX : PREFIX_singleIX.enable = 1;
         endcase
      end
   endtask

   task enable_all;
      begin
         PREFIX_singleIX.enable = 1;
      end
   endtask
   
   task write_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;
      begin
         check_master_num("write_single", master_num);
         case (master_num)
           IX : PREFIX_singleIX.write_single(addr, wdata);
         endcase
      end
   endtask

   task read_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0]  rdata;
      begin
         check_master_num("read_single", master_num);
         case (master_num)
           IX : PREFIX_singleIX.read_single(addr, rdata);
         endcase
      end
   endtask

   task insert_wr_cmd;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_wr_cmd", master_num);
         case (master_num)
           IX : PREFIX_singleIX.insert_wr_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_rd_cmd;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_rd_cmd", master_num);
         case (master_num)
           IX : PREFIX_singleIX.insert_rd_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_wr_data;
      input [31:0] master_num;
      input [DATA_BITS-1:0]  wdata;
      begin
         check_master_num("insert_wr_data", master_num);
         case (master_num)
           IX : PREFIX_singleIX.insert_wr_data(wdata);
         endcase
      end
   endtask

   task insert_wr_incr_data;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_wr_incr_data", master_num);
         case (master_num)
           IX : PREFIX_singleIX.insert_wr_incr_data(addr, len, size);
         endcase
      end
   endtask

   task insert_rand_chk;
      input [31:0] master_num;
      input [31:0] burst_num;
      begin
         check_master_num("insert_rand_chk", master_num);
         case (master_num)
           IX : PREFIX_singleIX.insert_rand_chk(burst_num);
         endcase
      end
   endtask

   

endmodule


