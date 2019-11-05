module dlatch_reset (  input data,           // 1-bit input pin for data
                  input en,          // 1-bit input pin for enabling the latch
                  input reset,        // 1-bit input pin for active-low reset
                  output reg q);     // 1-bit output pin for data output
 
   // This always block is "always" triggered whenever en/rstn/d changes
   // If reset is asserted then output will be zero
   // Else as long as enable is high, output q follows input d
   always @ (en or reset or data)
      if (!reset)
         q <= 0;
      else
         if (en)
            q <= data;
endmodule