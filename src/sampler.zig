const std = @import("std");
const lib = @import("lib.zig");
const string = lib.string;

fn Entropy(token_type: type) type {
    return struct {
        token: token_type,
        entropy: f64,
    };
}

fn sample_symb(rand: std.Random, symbols: anytype) Entropy(@TypeOf(symbols[0])) {
    return .{
        .token = symbols[rand.uintLessThan(usize, symbols.len)],
        .entropy = std.math.log2(@as(f64, @floatFromInt(symbols.len))),
    };
}

pub fn genfrompattern(rand: std.Random, writer: anytype, pattern: string) !f64 {
    var sl = pattern;
    var entropy: f64 = 0.0;
    while (sl.len > 0) {
        var c = sl[0];
        sl = sl[1..];
        if (c == '\\' and sl.len > 0) {
            c = sl[0];
            sl = sl[1..];
            try writer.writeByte(c);
            continue;
        }
        if (c == 'w' or c == 'W') {
            inline for (0.., .{ lib.a_c, lib.a_v, lib.a_cc, lib.a_tail }) |i, S| {
                const sc_ent = sample_symb(rand, S);
                const sc = sc_ent.token;
                entropy += sc_ent.entropy;
                if (i == 0 and c == 'W') {
                    try writer.writeByte(sc[0] + 'A' - 'a');
                    if (sc.len > 1) try writer.writeAll(sc[1..]);
                } else {
                    try writer.writeAll(sc);
                }
            }
        } else if (c == 's' or c == 'd') {
            const symbs = if (c == 's') "!$%&/=?^#*+@;>|:" else "1234567890";
            const sc_ent = sample_symb(rand, symbs);
            const sc = sc_ent.token;
            entropy += sc_ent.entropy;
            try writer.writeByte(sc);
        } else {
            try writer.writeByte(c);
        }
    }
    return entropy;
}
