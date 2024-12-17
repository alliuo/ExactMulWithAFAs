module AFA0(
    // error when input '111'
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire cout,
    output wire sum
);

    assign cout = (a & b) | (b & cin) | (a & cin);
    assign sum = ~cout & (a | b | cin);

endmodule
