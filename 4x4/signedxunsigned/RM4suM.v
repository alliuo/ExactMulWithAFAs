module RM4suM(
    input  wire [3:0] s, //signed
    input  wire [3:0] u, //unsigned
    output wire [7:0] out
);
    // PP encoding
    wire [1:0] ah, bh, al, bl;
    wire [3:0] pp_hh, pp_hl, pp_lh, pp_ll;

    assign ah = s[3:2];
    assign al = s[1:0];
    assign bh = u[3:2];
    assign bl = u[1:0];

    mul2_su  CODE_HH (.s(ah), .u(bh), .out(pp_hh));
    mul2_su  CODE_HL (.s(ah), .u(bl), .out(pp_hl));
    mul2_acc CODE_LH (.a(bh), .b(al), .out(pp_lh));
    mul2_acc CODE_LL (.a(al), .b(bl), .out(pp_ll));

    // PP reduction
    wire sum5, cout4, sum4, cout3, sum3, cout2, sum2, cout1, sum1, cout0, sum0;

    assign sum5 = ~pp_hh[3] ^ ~pp_hl[3];
    HA   HA4 (.a(pp_hh[2]), .b(pp_hl[3]),                 .cout(cout4), .sum(sum4));
    FA   FA3 (.a(pp_hh[1]), .b(pp_hl[3]), .cin(pp_lh[3]), .cout(cout3), .sum(sum3));
    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    AFA0 FA0 (.a(pp_hl[0]), .b(pp_lh[0]), .cin(pp_ll[2]), .cout(cout0), .sum(sum0));

    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};
    HA   RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    AFA1 RCA_FA0 (.a(sum2), .b(cout1), .cin(carry0), .cout(carry1), .sum(out[4]));
    AFA1 RCA_FA1 (.a(sum3), .b(cout2), .cin(carry1), .cout(carry2), .sum(out[5]));
    AFA4 RCA_FA2 (.a(sum4), .b(cout3), .cin(carry2), .cout(carry3), .sum(out[6]));
    assign out[7] = sum5 | cout4 | carry3;

endmodule
