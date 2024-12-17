module HA(
    input  wire a,
    input  wire b,
    output wire cout,
    output wire sum
);

    assign sum = a ^ b;
    assign cout = a & b;

endmodule
