module convyer (
    input wire clk,                 // 50MHz Clock from Cyclone II
    input wire reset,               // Push button (Active Low for Altera)
    input wire sensor_switch,       // Slide switch for box sensor (Input)
    input wire [3:0] target_val,    // 4 slide switches for target number (Input)
    output wire [3:0] count_leds,   // 4 Red LEDs to display Box Count Display (Output)
    output reg motor_led            // 1 Green LED for Conveyor Status (Output)
);

    // Internal wires acting as jumper cables between your blocks
    wire clean_sensor;
    wire sensor_pulse;
    reg [3:0] current_count;

    // 1. Debouncer: Removes switch bouncing[span_2](start_span)[span_2](end_span)
    debouncer U1 (
        .clk(clk),
        .switch_in(sensor_switch),
        .clean_out(clean_sensor)
    );

    // 2. Edge Detector: Generates one pulse when switch goes OFF -> ON[span_3](start_span)[span_3](end_span)
    edge_detector U2 (
        .clk(clk),
        .clean_signal(clean_sensor),
        .pulse_out(sensor_pulse)
    );

    // 3 & 4. Counter, Comparator, and Motor Control Logic
    always @(posedge clk) begin
        // Reset condition
        if (reset == 1'b0) begin 
            current_count <= 4'd0;
            motor_led <= 1'b1; // Motor ON = LED ON[span_4](start_span)[span_4](end_span)
        end
        else begin
            // Comparator: Compares count with target[span_5](start_span)[span_5](end_span)
            // If the target is greater than 0 and we hit the target, stop the motor.
            if (current_count >= target_val && target_val != 4'b0000) begin
                motor_led <= 1'b0; // Stops conveyor when count = target[span_6](start_span)[span_6](end_span)
            end
            else begin
                motor_led <= 1'b1; // Keep motor running
            end

            // Counter: Increments count for every pulse[span_7](start_span)[span_7](end_span)
            // It only increments if the pulse arrives AND the motor is currently running
            if (sensor_pulse == 1'b1 && motor_led == 1'b1) begin
                current_count <= current_count + 1'b1;
            end
        end
    end

    // Connect the internal register to the physical Box Count Display LEDs[span_8](start_span)[span_8](end_span)
    assign count_leds = current_count;

endmodule
