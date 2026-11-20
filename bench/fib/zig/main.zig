// fib - naive recursive Fibonacci, Zig
const std = @import("std");
const Io = std.Io;

fn fib(n: i64) i64 {
    return if (n < 2) n else fib(n - 1) + fib(n - 2);
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: i64 = if (args.len > 1) try std.fmt.parseInt(i64, args[1], 10) else 35;
    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\n", .{fib(n)});
    try out.flush();
}
