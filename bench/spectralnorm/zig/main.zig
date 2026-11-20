// spectralnorm benchmark, Zig
const std = @import("std");
const Io = std.Io;

fn evalA(i: usize, j: usize) f64 {
    return 1.0 / @as(f64, @floatFromInt((i + j) * (i + j + 1) / 2 + i + 1));
}

fn mulAv(v: []const f64, out: []f64) void {
    for (out, 0..) |*o, i| {
        var sum: f64 = 0;
        for (v, 0..) |x, j| sum += evalA(i, j) * x;
        o.* = sum;
    }
}

fn mulAtv(v: []const f64, out: []f64) void {
    for (out, 0..) |*o, i| {
        var sum: f64 = 0;
        for (v, 0..) |x, j| sum += evalA(j, i) * x;
        o.* = sum;
    }
}

fn mulAtAv(v: []const f64, out: []f64, tmp: []f64) void {
    mulAv(v, tmp);
    mulAtv(tmp, out);
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 100;
    const u = try arena.alloc(f64, n);
    const v = try arena.alloc(f64, n);
    const tmp = try arena.alloc(f64, n);
    @memset(u, 1.0);
    for (0..10) |_| {
        mulAtAv(u, v, tmp);
        mulAtAv(v, u, tmp);
    }
    var vbv: f64 = 0;
    var vv: f64 = 0;
    for (u, v) |a, b| {
        vbv += a * b;
        vv += b * b;
    }
    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d:.9}\n", .{@sqrt(vbv / vv)});
    try out.flush();
}
