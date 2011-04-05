<##//////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_ic_registry_resp.v

ITER MX
ITER SX   

LOOP MX
ITER MMX_IDX
ENDLOOP MX
  
module PREFIX_ic_registry_resp(PORTS);
   
   input 			    clk;
   input 			    reset;

   port 			    MMX_AGROUP_IC_AXI_CMD;
   
   input [ID_BITS-1:0] 	SSX_ID;
   input 			    SSX_VALID; 
   input 			    SSX_READY; 
   input 			    SSX_LAST; 
   output [MSTR_BITS-1:0] SSX_MSTR;
   output 			    SSX_OK;

   
   
   wire 			    Amatch_MMX_IDMMX_IDX;
   wire 			    match_MMX_IDMMX_IDX;
   wire 			    no_Amatch_MMX;
   
   wire 			    cmd_push_MMX;
   wire 			    cmd_push_MMX_IDMMX_IDX;
   
   wire 			    cmd_pop_SSX;
LOOP MX
   wire 			    cmd_pop_MMX_IDMMX_IDX;
ENDLOOP MX

   wire [SLV_BITS-1:0] 	slave_in_MMX_IDMMX_IDX;
   wire [SLV_BITS-1:0] 	slave_out_MMX_IDMMX_IDX;
   wire 			    slave_empty_MMX_IDMMX_IDX;
   wire 			    slave_full_MMX_IDMMX_IDX;

   reg [MSTR_BITS-1:0] 	ERR_MSTR_reg;
   wire [MSTR_BITS-1:0] ERR_MSTR;
   
   reg [MSTR_BITS-1:0] 	SSX_MSTR;
   reg 				    SSX_OK;

   
   
   
   assign 			    Amatch_MMX_IDMMX_IDX = MMX_AID == ID_MMX_IDMMX_IDX;
   
   assign 			    match_MMX_IDMMX_IDX  = SSX_ID == ID_MMX_IDMMX_IDX;

		   
   assign 			    cmd_push_MMX           = MMX_AVALID & MMX_AREADY;
   assign 			    cmd_push_MMX_IDMMX_IDX = cmd_push_MMX & Amatch_MMX_IDMMX_IDX;
   assign 			    cmd_pop_SSX            = SSX_VALID & SSX_READY & SSX_LAST;
   
   LOOP MX
     assign 			    cmd_pop_MMX_IDMMX_IDX = CONCAT((cmd_pop_SSX & (SSX_ID == ID_MMX_IDMMX_IDX)) |);
   ENDLOOP MX
   
				    
   assign 			    slave_in_MMX_IDMMX_IDX = MMX_ASLV;




IFDEF DEF_DECERR_SLV
   LOOP MX
     assign 			    no_Amatch_MMX         = CONCAT((~Amatch_MMX_IDMMX_IDX) &);
   ENDLOOP MX
   

   always @(posedge clk or posedge reset)
     if (reset)
       ERR_MSTR_reg <= #FFD {MSTR_BITS{1'b0}};
   LOOP MX
     else if (cmd_push_MMX & no_Amatch_MMX)
       ERR_MSTR_reg <= #FFD 'dMX;
   ENDLOOP MX
   
   assign 			    ERR_MSTR = ERR_MSTR_reg;
ELSE DEF_DECERR_SLV
   assign 			    ERR_MSTR = 'd0;
ENDIF DEF_DECERR_SLV
          
   
LOOP SX
   always @(SSX_ID or ERR_MSTR)                                               
     begin                                                                     
	case (SSX_ID)
          LOOP MX
	  ID_MMX_IDMMX_IDX : SSX_MSTR = 'dMX;
	  ENDLOOP MX
	  default : SSX_MSTR = ERR_MSTR;                                      
	endcase                                                                
     end                                                                       
   
   always @(*)                                                                  
     begin                                                                     
	case (SSX_ID)
	  LOOP MX
	  ID_MMX_IDMMX_IDX : SSX_OK = slave_out_MMX_IDMMX_IDX == 'dSX;
	  ENDLOOP MX
	  default : SSX_OK = 1'b1; //SLVERR                                   
	endcase                                                                
     end                                                                       
ENDLOOP SX

CREATE prgen_fifo.v DEFCMD(SWAP CONST(#FFD) #FFD)
LOOP MX
LOOP MMX_IDX
   prgen_fifo #(SLV_BITS, CMD_DEPTH)
   slave_fifo_MMX_IDMMX_IDX(                             
                    .clk(clk),                              
                    .reset(reset),                          
                    .push(cmd_push_MMX_IDMMX_IDX),       
                    .pop(cmd_pop_MMX_IDMMX_IDX),         
                    .din(slave_in_MMX_IDMMX_IDX),        
                    .dout(slave_out_MMX_IDMMX_IDX),      
		            .empty(slave_empty_MMX_IDMMX_IDX),   
		            .full(slave_full_MMX_IDMMX_IDX)      
                    );
   
ENDLOOP MMX_IDX
ENDLOOP MX
   

endmodule

   
