module edge_detector (
    input wire clk,
    input wire clean_signal, // This comes from the Debouncer
    output wire pulse_out    // The single 1-clock-cycle PING
);

    reg past_state;
    reg current_state;

    always @(posedge clk) begin
        // Shift the data through two flip-flops to remember time
        current_state <= clean_signal;
        past_state    <= current_state; 
    end

    // A pulse is ONLY generated if the current state is 1 (ON) 
    // AND the past state was 0 (OFF). 
    assign pulse_out = current_state & ~past_state;

endmodule
