`timescale 1ns / 1ps

module tb_top;

reg clk;
reg reset;
wire done;

// Instantiate design
top uut (
    .clk(clk),
    .reset(reset),
    .done(done)
);

// Clock generation (10ns period)
initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset = 1;
    #20;
    reset = 0;

    // Wait for done (file will already be written by this point)
    wait(done);

    #10;
    $display("SUCCESS: Simulation complete. output.hex has been written.");
    $finish;
end

endmodule
