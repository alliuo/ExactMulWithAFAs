module cla_8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire       cout,
    output wire [7:0] sum 
);
    wire [7:0] g;   // Generate signals
    wire [7:0] p;   // Propagate signals
    wire [6:0] c;   // Internal Carry signals

    // Generate and Propagate signals
    assign g = a & b;    // Generate: Gi = Ai & Bi
    assign p = a ^ b;    // Propagate: Pi = Ai ^ Bi

    // Carry Chain
    assign c[0] = g[0] | (p[0] & cin);
    assign c[1] = g[1] | (p[1] & c[0]);
    assign c[2] = g[2] | (p[2] & c[1]);
    assign c[3] = g[3] | (p[3] & c[2]);
    
    wire mid_c;
    assign mid_c = (cin & p[0] & p[1] & p[2] & p[3]) | (g[0] & p[1] & p[2] & p[3]) | (g[1] & p[2] & p[3]) | (g[2] & p[3]) | g[3];
    
    assign c[4] = g[4] | (p[4] & mid_c);
    assign c[5] = g[5] | (p[5] & c[4]);
    assign c[6] = g[6] | (p[6] & c[5]);
    assign cout = g[7] | (p[7] & c[6]);

    // Sum
    assign sum = p ^ {c, cin}; // Sum: Si = Pi ^ Ci

endmodule
