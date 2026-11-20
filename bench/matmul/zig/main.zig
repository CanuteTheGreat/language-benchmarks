// matmul - naive matrix multiply (i,k,j), Zig
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 400;
    const gpa = init.gpa;
    const a = try gpa.alloc(f64, n * n);
    defer gpa.free(a);
    const b = try gpa.alloc(f64, n * n);
    defer gpa.free(b);
    const c = try gpa.alloc(f64, n * n);
    defer gpa.free(c);
    @memset(c, 0);
    for (0..n) |i| {
        for (0..n) |j| {
            a[i * n + j] = @floatFromInt((i + j) % 10);
            b[i * n + j] = @floatFromInt((i * j) % 10);
        }
    }
    for (0..n) |i| {
        for (0..n) |k| {
            const aik = a[i * n + k];
            for (0..n) |j| c[i * n + j] += aik * b[k * n + j];
        }
    }
    var sum: f64 = 0;
    for (c) |v| sum += v;
    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\n", .{@as(i64, @intFromFloat(sum))});
    try out.flush();
}
