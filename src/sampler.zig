const std = @import("std");
const lib = @import("lib.zig");
const map = lib.map;
const string = lib.string;

fn Entropy(token_type: type) type {
    return struct {
        token: token_type,
        entropy: f64,
    };
}

fn sample_next_token(rand: std.Random, seed: string) Entropy(string) {
    var tok = seed[0..];
    var next = map.get(tok);
    while (next == null) {
        if (tok.len == 0) {
            return Entropy(string){
                .token = "",
                .entropy = 0.0,
            };
        }
        tok = tok[1..];
        next = map.get(tok);
    }

    const tokens = next.?;
    return Entropy(string){
        .token = tokens[rand.uintLessThan(usize, tokens.len)],
        .entropy = std.math.log2(@as(f64, @floatFromInt(tokens.len))),
    };
}

fn sample_symb(rand: std.Random, symbols: string) Entropy(u8) {
    return Entropy(u8){
        .token = symbols[rand.uintLessThan(usize, symbols.len)],
        .entropy = std.math.log2(@as(f64, @floatFromInt(symbols.len))),
    };
}

fn is_uppercase(c: u8) bool {
    return c >= 'A' and c <= 'Z';
}

fn ContextBuffer(size: usize) type {
    return struct {
        const Self = @This();
        buf: [size]u8,
        fn init() Self {
            return Self{ .buf = [_]u8{' '} ** size };
        }
        fn put(self: *Self, c: u8) void {
            for (0..self.buf.len -| 1) |i| {
                self.buf[i] = self.buf[i + 1];
            }
            if (is_uppercase(c)) {
                self.buf[self.buf.len -| 1] = c - 'A' + 'a';
            } else {
                self.buf[self.buf.len -| 1] = c;
            }
        }
        fn write(self: *Self, s: string) void {
            for (s) |c| {
                self.put(c);
            }
        }
    };
}

pub fn genfrompattern(rand: std.Random, writer: anytype, pattern: string) !f64 {
    var ctx = ContextBuffer(lib.chain_depth).init();
    var sl = pattern;
    var entropy: f64 = 0.0;
    while (sl.len > 0) {
        var c = sl[0];
        sl = sl[1..];
        if (c == '\\' and sl.len > 0) {
            c = sl[0];
            sl = sl[1..];
            try writer.writeByte(c);
            ctx.put(c);
            continue;
        }
        if (c == 'w' or c == 't' or c == 'T' or c == 'W') {
            var pushed: usize = 0;
            var j: usize = 0;
            while (pushed < 6) : (j += 1) {
                const next_ent = sample_next_token(rand, &ctx.buf);
                const next = next_ent.token;
                pushed += next.len;
                entropy += next_ent.entropy;
                ctx.write(next);
                if (j == 0 and is_uppercase(c)) {
                    for (next, 0..) |sc, k| {
                        if (k == 0) {
                            try writer.writeByte(sc + 'A' - 'a');
                        } else {
                            try writer.writeByte(sc);
                        }
                    }
                } else {
                    try writer.writeAll(next);
                }
                if (c == 't' or c == 'T') break;
            }
        } else if (c == 's' or c == 'd') {
            const symbs = if (c == 's') "!$%&/=?^#*+@;>|:" else "1234567890";
            const sc_ent = sample_symb(rand, symbs);
            const sc = sc_ent.token;
            ctx.put(sc);
            entropy += sc_ent.entropy;
            try writer.writeByte(sc);
        } else {
            ctx.put(c);
            try writer.writeByte(c);
        }
    }
    return entropy;
}
