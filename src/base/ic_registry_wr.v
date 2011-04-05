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

OUTFILE PREFIX_ic_registry_wr.v

ITER MX
ITER SX   

LOOP MX
ITER MMX_IDX
ENDLOOP MX
  
module PREFIX_ic_registry_wr(PORTS);
   

   
   input 			    clk;
   input 			    reset;

   port 			    MMX_AWGROUP_IC_AXI_CMD;
   
   input [ID_BITS-1:0]  MMX_WID;
   input 			    MMX_WVALID; 
   input 			    MMX_WREADY; 
   input 			    MMX_WLAST; 
   output [SLV_BITS-1:0] MMX_WSLV;
   output 			    MMX_WOK;
   
   input 			    SSX_AWVALID;
   input 			    SSX_AWREADY;
   input [MSTR_BITS-1:0] SSX_AWMSTR;
   input 			    SSX_WVALID;
   input 			    SSX_WREADY;
   input 			    SSX_WLAST;
   
   
   wire 			    AWmatch_MMX_IDMMX_IDX;
   wire 			    Wmatch_MMX_IDMMX_IDX;

   wire 			    cmd_push_MMX;
   wire 			    cmd_push_MMX_IDMMX_IDX;
   
   wire 			    cmd_pop_MMX;
   wire 			    cmd_pop_MMX_IDMMX_IDX;

   wire [SLV_BITS-1:0] 	slave_in_MMX_IDMMX_IDX;
   wire [SLV_BITS-1:0] 	slave_out_MMX_IDMMX_IDX;
   wire 			    slave_empty_MMX_IDMMX_IDX;
   wire 			    slave_full_MMX_IDMMX_IDX;

   wire 			    cmd_push_SSX;
   wire 			    cmd_pop_SSX;
   wire [MSTR_BITS-1:0] master_in_SSX;
   wire [MSTR_BITS-1:0] master_out_SSX;
   wire 			    master_empty_SSX;
   wire 			    master_full_SSX;
   
   reg [SLV_BITS-1:0] 	MMX_WSLV;
   reg 				    MMX_WOK;

   
   
   
   assign                           AWmatch_MMX_IDMMX_IDX  = MMX_AWID == ID_MMX_IDMMX_IDX;
      
   assign 			    Wmatch_MMX_IDMMX_IDX   = MMX_WID == ID_MMX_IDMMX_IDX;
		   
		   
   assign 			    cmd_push_MMX           = MMX_AWVALID & MMX_AWREADY;
   assign 			    cmd_push_MMX_IDMMX_IDX = cmd_push_MMX & AWmatch_MMX_IDMMX_IDX;
   assign 			    cmd_pop_MMX            = MMX_WVALID & MMX_WREADY & MMX_WLAST;
   assign  			    cmd_pop_MMX_IDMMX_IDX  = cmd_pop_MMX & Wmatch_MMX_IDMMX_IDX;

   assign 			    cmd_push_SSX           = SSX_AWVALID & SSX_AWREADY;
   assign 			    cmd_pop_SSX            = SSX_WVALID & SSX_WREADY & SSX_WLAST;
   assign 			    master_in_SSX          = SSX_AWMSTR;
   
   assign 			    slave_in_MMX_IDMMX_IDX = MMX_AWSLV;

   
   LOOP MX
   always @(MMX_WID                                                       
	    or slave_out_MMX_IDMMX_IDX                                   
	    )                                                              
     begin                                                                 
	case (MMX_WID)                                                    
	  ID_MMX_IDMMX_IDX : MMX_WSLV = slave_out_MMX_IDMMX_IDX; 
	  default : MMX_WSLV = SERR;                           
	endcase                                                            
     end   

   always @(MMX_WSLV                                                      
	    or master_out_SSX                                              
	    )                                                              
     begin                                                                 
	case (MMX_WSLV)                                                   
	  'dSX : MMX_WOK = master_out_SSX == 'dMX;                       
	  default : MMX_WOK = 1'b0;                                       
	endcase                                                            
     end                                                                   

   ENDLOOP MX
      
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

	
   
   LOOP SX
   prgen_fifo #(MSTR_BITS, 32)
   master_fifo_SSX(                                            
		   .clk(clk),                                   
		   .reset(reset),                               
		   .push(cmd_push_SSX),                        
		   .pop(cmd_pop_SSX),                          
		   .din(master_in_SSX),                        
		   .dout(master_out_SSX),                      
		   .empty(master_empty_SSX),                   
		   .full(master_full_SSX)                      
		   );                                           

   ENDLOOP SX
   
endmodule

   
