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

OUTFILE PREFIX_ic_dec.v

ITER MX   
ITER SX   

LOOP MX
ITER MMX_IDX
ENDLOOP MX
  
module PREFIX_ic_dec (PORTS);

   input [ADDR_BITS-1:0] 		      MMX_AADDR;
   input [ID_BITS-1:0] 			      MMX_AID;
   output [SLV_BITS-1:0] 		      MMX_ASLV;
   output 				      MMX_AIDOK;

   parameter 				      DEC_MSB =  ADDR_BITS - 1;
   parameter 				      DEC_LSB =  ADDR_BITS - SLV_BITS;
   
   reg [SLV_BITS-1:0] 			      MMX_ASLV;
   reg 					      MMX_AIDOK;
   
   LOOP MX
     always @(MMX_AADDR or MMX_AIDOK)                       
       begin        
IFDEF TRUE(SLAVE_NUM==1)              
	  case (MMX_AIDOK)    
	    1'b1 : MMX_ASLV = 'd0;  
ELSE TRUE(SLAVE_NUM==1)                                          
	  case ({MMX_AIDOK, MMX_AADDR[DEC_MSB:DEC_LSB]})    
	    {1'b1, BIN(SX SLV_BITS)} : MMX_ASLV = 'dSX;  
ENDIF TRUE(SLAVE_NUM==1)   
            default : MMX_ASLV = 'dSERR;                     
	  endcase                                             
       end                                                    

   always @(MMX_AID)                                  
     begin                                             
	case (MMX_AID)                                
	  ID_MMX_IDMMX_IDX : MMX_AIDOK = 1'b1; 
	  default : MMX_AIDOK = 1'b0;                 
	endcase                                        
     end    
  
   ENDLOOP MX
      
     endmodule



