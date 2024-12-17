module RM4sM(
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] out
);
    // PP encoding
    wire [1:0] ah, bh, al, bl;
    wire [3:0] pp_hh, pp_hl, pp_lh, pp_ll;

    assign ah = a[3:2];
    assign al = a[1:0];
    assign bh = b[3:2];
    assign bl = b[1:0];

    mul2_signed CODE_HH (.a(ah), .b(bh), .out(pp_hh));
    mul2_su     CODE_HL (.s(ah), .u(bl), .out(pp_hl));
    mul2_su     CODE_LH (.s(bh), .u(al), .out(pp_lh));
    mul2_acc    CODE_LL (.a(al), .b(bl), .out(pp_ll));

    // PP reduction
    wire cout4, sum4, cout3, sum3, cout2, sum2, cout1, sum1, cout0, sum0;

    assign cout4 = pp_hh[2];
    assign sum4 = ~pp_hh[2];
    FA   FA3 (.a(pp_hh[1]), .b(~pp_hl[3]), .cin(~pp_lh[3]), .cout(cout3), .sum(sum3));
    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    AFA0 FA0 (.a(pp_hl[0]), .b(pp_lh[0]), .cin(pp_ll[2]), .cout(cout0), .sum(sum0));

    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};
    HA   RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    AFA1 RCA_FA0 (.a(sum2), .b(cout1), .cin(carry0), .cout(carry1), .sum(out[4]));
    AFA0 RCA_FA1 (.a(sum3), .b(cout2), .cin(carry1), .cout(carry2), .sum(out[5]));
    AFA3 RCA_FA2 (.a(sum4), .b(cout3), .cin(carry2), .cout(carry3), .sum(out[6]));

    assign out[7] = ~(~pp_hh[3] & (cout4 | carry3));
endmodule
