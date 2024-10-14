pub fn main() !void {
    const std = @import("std");
    const beg_readme =
        \\# Zig Password Generator (zigpwgen)
        \\
        \\`zigpwgen` is a flexible password generator designed to produce passphrases that balance security and pronounceability. It is based on a pattern system where words, tokens, symbols, and digits can be flexibly combined. Built with the Zig programming language, `zigpwgen` ensures performance, clarity, and simplicity.
        \\
        \\## Features
        \\- **Pronounceable Words**: Uses tokens from the EFF long word list to generate memorable passphrases.
        \\- **Customizable Patterns**: Define your own password structure using a simple pattern syntax.
        \\- **Efficient and Fast**: Built with Zig, ensuring minimal runtime overhead and clear, maintainable code.
        \\
        \\## Installation
        \\
        \\Clone the repository and build with Zig:
        \\
        \\```sh
        \\git clone https://github.com/francescoalemanno/zigpwgen.git
        \\cd zigpwgen
        \\zig build -Doptimize=ReleaseFast
        \\```
        \\
        \\or download one of the [precompiled release binaries](https://github.com/francescoalemanno/zigpwgen/releases/tag/{s}).
        \\
        \\## Usage
        \\
        \\### Command Syntax
        \\
        \\```sh
        \\
    ;
    const beg_end =
        \\```
        \\
        \\# License
        \\
        \\MIT License
        \\
        \\Copyright (c) 2024 Francesco Alemanno
        \\
    ;
    const main_prog = @import("src/main.zig");
    var buf: [100000]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(&buf);
    var alist = std.ArrayList(u8).init(alloc.allocator());

    const out = alist.writer();
    out.print(beg_readme, .{main_prog.VERSION}) catch unreachable;
    main_prog.format_help(out) catch unreachable;
    out.writeAll(beg_end) catch unreachable;

    const file = try std.fs.cwd().createFile(
        "README.md",
        .{ .read = true },
    );
    defer file.close();
    try file.writeAll(alist.items);
}
