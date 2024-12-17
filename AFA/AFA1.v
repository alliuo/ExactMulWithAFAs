module AFA1(
    // error when input '011'
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire cout,
    output wire sum
);

    assign cout = a & (b | cin);
    assign sum = (a | b | cin) & ((b & cin) | ~cout);

endmodule
