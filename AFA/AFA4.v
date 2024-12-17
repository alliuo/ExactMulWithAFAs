module AFA4(
    // error when input '101' or '011' or '111'
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire cout,
    output wire sum
);
    
    assign cout = a & b;
    assign sum = ~cout & (a | b | cin);

endmodule
