// factorial - N! with std.math.big.int, Zig.
const std = @import("std");
const Io = std.Io;
const big = std.math.big.int;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: u64 = if (args.len > 1) try std.fmt.parseInt(u64, args[1], 10) else 100;

    var f = try big.Managed.initSet(gpa, 1);
    defer f.deinit();
    var m = try big.Managed.init(gpa);
    defer m.deinit();
    var i: u64 = 2;
    while (i <= n) : (i += 1) {
        try m.set(i);
        try f.mul(&f, &m);
    }

    const s = try f.toString(gpa, 10, .lower);
    defer gpa.free(s);
    var sum: u64 = 0;
    for (s) |c| sum += c - '0';

    var buf: [128]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d}\n", .{ s.len, sum });
    try out.flush();
}
