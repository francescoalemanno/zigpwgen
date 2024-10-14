const std = @import("std");
const sampler = @import("sampler.zig");
const default_pattern = "W-w-w-w-ds";
const default_print_entropy = false;
const default_number_of_passwords = 5;
const string = []const u8;

fn matches_cli_opt(option: string, cli_arg: string) bool {
    return std.mem.eql(u8, cli_arg, option[1..3]) or std.mem.eql(u8, cli_arg, option);
}

pub fn main() !void {
    //Prepare buffered writer
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    defer {
        bw.flush() catch unreachable;
    }
    //Prepare CSPRNG
    var seed = [1]u8{0} ** std.Random.ChaCha.secret_seed_length;
    try std.posix.getrandom(&seed);
    var chacha = std.Random.ChaCha.init(seed);
    const rand = chacha.random();
    //Get args iterator
    var arg_iter = std.process.args();

    var number_of_passwords: usize = default_number_of_passwords;
    var pattern: []const u8 = default_pattern;
    var print_entropy: bool = default_print_entropy;

    while (arg_iter.next()) |arg| {
        if (matches_cli_opt("--num", arg)) {
            if (arg_iter.next()) |ns| {
                number_of_passwords = try std.fmt.parseInt(usize, ns, 10);
            }
        } else if (matches_cli_opt("--pattern", arg)) {
            if (arg_iter.next()) |ps| {
                pattern = ps;
            }
        } else if (matches_cli_opt("--entropy", arg)) {
            print_entropy = true;
        } else if (matches_cli_opt("--help", arg)) {
            try stdout.print(
                \\Usage: zigpwgen [-p <pattern>] [-n <num>] [-e]
                \\
                \\Flexible password generator using the EFF long word list for pronounceable words. 
                \\Built with Zig for performance and simplicity.
                \\
                \\Options:
                \\  -p, --pattern     string representing the desired structure of the generated passphrases,
                \\                    defaults to `{s}` (w = word; t = token; s = symbol; d = digit).
                \\
                \\  -n, --num         number of passphrases to generate,
                \\                    defaults to {}.
                \\
                \\  -e, --entropy     print entropy in base log2 along with the generated password,
                \\                    defaults to {?}.
                \\                    
                \\  --help            display usage information
                \\
                \\  -----------------------------------------------------------------------------------------
                \\  author: Francesco Alemanno <francescolemanno710@gmail.com>.
                \\  repo:   https://github.com/francescoalemanno/zigpwgen
                \\
            , .{ default_pattern, default_number_of_passwords, default_print_entropy });
            return;
        }
    }

    for (0..number_of_passwords) |_| {
        const entropy = try sampler.genfrompattern(rand, stdout, pattern);
        if (print_entropy) try stdout.print("   {d:.2}", .{entropy});
        try stdout.writeByte('\n');
    }
}
