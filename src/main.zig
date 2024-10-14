const std = @import("std");
const sampler = @import("sampler.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    defer {
        // stdout.print("hallo!", .{}) catch unreachable;
        bw.flush() catch unreachable;
    }
    var seed = [1]u8{0} ** std.Random.ChaCha.secret_seed_length;
    try std.posix.getrandom(&seed);
    var chacha = std.Random.ChaCha.init(seed);
    const rand = chacha.random();
    var n: usize = 5;
    var p: []const u8 = "w.w.w.ddss";
    var arg_iter = std.process.args();
    var print_entropy: bool = false;
    while (arg_iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--num")) {
            if (arg_iter.next()) |ns| {
                n = try std.fmt.parseInt(usize, ns, 10);
            }
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--pattern")) {
            if (arg_iter.next()) |ps| {
                p = ps;
            }
        } else if (std.mem.eql(u8, arg, "-e") or std.mem.eql(u8, arg, "--entropy")) {
            print_entropy = true;
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
                \\  -e, --entropy     print entropy in base log2 along with the generated password.
                \\                    
                \\  --help            display usage information
                \\            
            , .{});
            return;
        }
    }
    for (0..n) |_| {
        const entropy = try sampler.genfrompattern(rand, stdout, p);
        if (print_entropy) try stdout.print("   {d:.2}", .{entropy});
        try stdout.writeByte('\n');
    }
}
