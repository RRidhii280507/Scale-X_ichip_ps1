`timescale 1ns / 1ps

module top #(
    parameter H_IN  = 480,
    parameter W_IN  = 640,
    parameter H_OUT = 1080,
    parameter W_OUT = 1920,
    parameter NO_OF_CHANNELS = 3,
    parameter FP = 8   // fractional bits
)(
    input clk,
    input reset,
    output reg done
);

reg [7:0] input_image  [0:(H_IN * W_IN * NO_OF_CHANNELS - 1)];
reg [7:0] output_image [0:(H_OUT * W_OUT * NO_OF_CHANNELS - 1)];

integer xout, yout, i, x0, y0, x1, y1;

// Fixed-point variables
integer xin,yin,a,b;

integer I00, I01, I10, I11;
integer sum;

initial begin
    done = 0;
    $readmemh("input.mem", input_image);

    for (i = 0; i < NO_OF_CHANNELS; i = i + 1) begin
        for (yout = 0; yout < H_OUT; yout = yout + 1) begin
            for (xout = 0; xout < W_OUT; xout = xout + 1) begin

                // Fixed-point coordinate mapping
                xin = (xout * W_IN << FP) / W_OUT;
                yin = (yout * H_IN << FP) / H_OUT;
                // integer part
                x0 = xin >> FP;
                y0 = yin >> FP;
                
                x1 = (x0 + 1 < W_IN) ? x0 + 1 : x0;
                y1 = (y0 + 1 < H_IN) ? y0 + 1 : y0;

                // fractional part
                a = xin & ((1 << FP) - 1);
                b = yin & ((1 << FP) - 1);

                // Read pixels
                I00 = input_image[NO_OF_CHANNELS*(y0*W_IN + x0)+i];
                I10 = input_image[NO_OF_CHANNELS*(y0*W_IN + x1)+i];
                I01 = input_image[NO_OF_CHANNELS*(y1*W_IN + x0)+i];
                I11 = input_image[NO_OF_CHANNELS*(y1*W_IN + x1)+i];

                // Bilinear interpolation in fixed-point
                sum =
                    (( ( (1<<FP) - a ) * ( (1<<FP) - b ) * I00 ) +
                     ( a * ( (1<<FP) - b ) * I10 ) +
                     ( ( (1<<FP) - a ) * b * I01 ) +
                     ( a* b * I11 )) >> (2*FP);

                // Clamp to 8-bit
                if (sum > 255) sum = 255;
                if (sum < 0) sum = 0;

                output_image[NO_OF_CHANNELS*(yout*W_OUT + xout)+i] = sum[7:0];

            end
        end
    end

    $writememh("output.hex", output_image);
    done = 1;
end

endmodule
