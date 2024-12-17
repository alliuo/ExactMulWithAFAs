
module mul2_su (
    // signed x unsigned 2x2 multiplier
    input  wire [1:0] s, //signed
    input  wire [1:0] u, //unsigned
    output wire [3:0] out
);
    wire [3:0] pp;

    assign pp[3] = s[1] & u[1];
    assign pp[2] = s[1] & u[0];
    assign pp[1] = s[0] & u[1];
    assign pp[0] = s[0] & u[0];

    assign out[0] = pp[0];
    assign out[1] = pp[2] ^ pp[1];
    assign out[2] = out[3] & (~(u[0] & u[1]) | s[0]);
    assign out[3] = pp[2] | pp[3];

endmodule
