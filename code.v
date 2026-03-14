`timescale 1ns / 1ps

module top #(
    parameter H_IN  = 480,
    parameter W_IN  = 640,
    parameter H_OUT = 1080,
    parameter W_OUT = 1920,
    parameter NO_OF_CHANNELS = 3
)(
    input  clk,
    input  reset,
    output reg done
);

reg [7:0] input_image  [0:(H_IN  * W_IN  * NO_OF_CHANNELS - 1)];
reg [7:0] output_image [0:(H_OUT * W_OUT * NO_OF_CHANNELS - 1)];

integer xout, yout, x0, y0, x1, y1,i;
real    xin, yin, a, b;

initial begin
    done = 0;
    $readmemh("input.mem", input_image);

        for(i=0;i<NO_OF_CHANNELS;i=i+1) begin
        for (yout = 0; yout < H_OUT; yout = yout + 1) begin
        for (xout = 0; xout < W_OUT; xout = xout + 1) begin
            xin = xout * W_IN * 1.0 / W_OUT;
            yin = yout * H_IN * 1.0 / H_OUT;
            x0  = xout * W_IN / W_OUT;
            y0  = yout * H_IN / H_OUT;
            x1  = (x0 + 1 < W_IN) ? x0 + 1 : x0;
            y1  = (y0 + 1 < H_IN) ? y0 + 1 : y0;
            a   = xin - x0;
            b   = yin - y0;

            output_image[NO_OF_CHANNELS*(yout*W_OUT + xout)+i] =
                (1-a)*(1-b) * $itor(input_image[NO_OF_CHANNELS*(y0*W_IN + x0)+i])
              + a    *(1-b) * $itor(input_image[NO_OF_CHANNELS*(y0*W_IN + x1)+i])
              + (1-a)*b     * $itor(input_image[NO_OF_CHANNELS*(y1*W_IN + x0)+i])
              + a    *b     * $itor(input_image[NO_OF_CHANNELS*(y1*W_IN + x1)+i]);
        end
    end
end
    // Everything done — write output and signal completion
    $writememh("output.hex", output_image);
    done = 1;
end

endmodule