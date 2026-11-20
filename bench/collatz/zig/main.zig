// collatz - longest Collatz sequence below N, Zig
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const limit: i64 = if (args.len > 1) try std.fmt.parseInt(i64, args[1], 10) else 1000000;
    var best: i64 = 1;
    var best_steps: u32 = 0;
    var s: i64 = 1;
    while (s < limit) : (s += 1) {
        var n = s;
        var steps: u32 = 0;
        while (n != 1) {
            n = if (n & 1 == 1) 3 * n + 1 else @divTrunc(n, 2);
            steps += 1;
        }
        if (steps > best_steps) {
            best_steps = steps;
            best = s;
        }
    }
    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d}\n", .{ best, best_steps });
    try out.flush();
}
