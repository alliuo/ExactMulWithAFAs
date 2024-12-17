module AFA3(
    // error when input '001' or '011' or '111'
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire cout,
    output wire sum
);

    assign cout = cin | (a & b);
    assign sum = ~cout & (a | b);

endmodule
