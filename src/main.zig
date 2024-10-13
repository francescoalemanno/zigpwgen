const std = @import("std");
const lib = @import("lib.zig");
const map = lib.map;
const string = lib.string;

fn sample_next_token(rand: std.Random, seed: []const u8) []const u8 {
    var tok = seed[0..];
    var next = map.get(tok);
    while (next == null) {
        if (tok.len == 0) {
            return "";
        }
        tok = tok[1..];
        next = map.get(tok);
    }

    const tokens = next.?;
    return tokens[rand.uintLessThan(usize, tokens.len)];
}

fn sample_symb(rand: std.Random, symbols: []const u8) u8 {
    return symbols[rand.uintLessThan(usize, symbols.len)];
}

fn is_uppercase(c: u8) bool {
    return c >= 'A' and c <= 'Z';
}
fn ContextBuffer(size: usize) type {
    return struct {
        const ST = @This();
        buf: [size]u8,
        fn init() ST {
            return ST{ .buf = [_]u8{' '} ** size };
        }
        fn put(self: *ST, c: u8) void {
            for (0..self.buf.len -| 1) |i| {
                self.buf[i] = self.buf[i + 1];
            }
            if (is_uppercase(c)) {
                self.buf[self.buf.len -| 1] = c - 'A' + 'a';
            } else {
                self.buf[self.buf.len -| 1] = c;
            }
        }
        fn write(self: *ST, s: []const u8) void {
            for (s) |c| {
                self.put(c);
            }
        }
    };
}
fn genfrompattern(rand: std.Random, writer: anytype, pattern: []const u8) !void {
    var mem = ContextBuffer(3).init();
    var sl = pattern;
    while (sl.len > 0) {
        var c = sl[0];
        sl = sl[1..];
        if (c == '\\' and sl.len > 0) {
            c = sl[0];
            sl = sl[1..];
            try writer.writeByte(c);
            mem.put(c);
            continue;
        }
        if (c == 'w' or c == 't' or c == 'T' or c == 'W') {
            for (0..3) |j| {
                const next = sample_next_token(rand, &mem.buf);
                mem.write(next);
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
            const sc = sample_symb(rand, symbs);
            mem.put(sc);
            try writer.writeByte(sc);
        } else {
            mem.put(c);
            try writer.writeByte(c);
        }
    }
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    var seed = [1]u8{0} ** std.Random.ChaCha.secret_seed_length;
    try std.posix.getrandom(&seed);
    var chacha = std.Random.ChaCha.init(seed);
    const rand = chacha.random();
    var n: usize = 5;
    var p: []const u8 = "w.w.w.ddss";
    var arg_iter = std.process.args();
    while (arg_iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--num")) {
            if (arg_iter.next()) |ns| {
                n = try std.fmt.parseInt(usize, ns, 10);
            }
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--pattern")) {
            if (arg_iter.next()) |ps| {
                p = ps;
            }
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try stdout.print(
                \\Usage: zigpwgen [-p <pattern>] [-n <num>]
                \\
                \\Flexible password generator with pronounceable words based on EFF long word list and Zig.
                \\
                \\Options:
                \\  -p, --pattern     string representing the desired structure of the generated
                \\                    passphrases, default is `w.w.w.ddss` (w = word; t = token; s = symbol; d = digit).
                \\
                \\  -n, --num         number of passphrases to generate, must be a positive integer.
                \\                    
                \\  --help            display usage information
                \\            
            , .{});
            try bw.flush();
            return;
        }
    }
    for (0..n) |_| {
        try genfrompattern(rand, stdout, p);
        try stdout.writeByte('\n');
    }
    try bw.flush();
}
