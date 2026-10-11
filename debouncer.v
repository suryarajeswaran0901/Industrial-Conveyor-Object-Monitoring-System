module debouncer (
    input wire clk,         // The 50MHz board clock
    input wire switch_in,   // The raw, bouncy signal from the physical switch
    output reg clean_out    // The clean, stable signal
);

    // A 20-bit counter can count up to 1,048,575. 
    // Counting to 1,000,000 at 50MHz takes exactly 20 milliseconds.
    reg [19:0] counter;     
    reg sync_switch;        // Used to align the physical switch to our clock

    always @(posedge clk) begin
        sync_switch <= switch_in; 
        
        // If the current switch state matches our clean output, do nothing
        if (clean_out == sync_switch) begin 
            counter <= 0; 
        end 
        // If they don't match, start counting. 
        else begin
            counter <= counter + 1'b1;
            
            // If the switch stays stable for 1,000,000 clock cycles (20ms)
            if (counter == 20'd1000000) begin
                clean_out <= sync_switch; // Update the clean output
                counter <= 0;             // Reset the timer
            end
        end
    end
endmodule
