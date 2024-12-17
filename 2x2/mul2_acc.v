
module mul2_acc (
    // unsigned 2x2 multiplier
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] out
);

    wire [3:0] pp;

    assign pp[3] = a[1] & b[1];
    assign pp[2] = a[1] & b[0];
    assign pp[1] = a[0] & b[1];
    assign pp[0] = a[0] & b[0];

    assign out[0] = pp[0];
    assign out[1] = pp[2] ^ pp[1];
    assign out[2] = pp[3] & ~pp[0];
    assign out[3] = pp[3] & pp[0];

endmodule
