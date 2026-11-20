// spectralnorm benchmark, Zig (std.Thread)
const std = @import("std");
const Io = std.Io;

fn evalA(i: usize, j: usize) f64 {
    return 1.0 / @as(f64, @floatFromInt((i + j) * (i + j + 1) / 2 + i + 1));
}

fn rowsAv(v: []const f64, out: []f64, lo: usize, hi: usize) void {
    for (lo..hi) |i| {
        var sum: f64 = 0;
        for (v, 0..) |x, j| sum += evalA(i, j) * x;
        out[i] = sum;
    }
}

fn rowsAtv(v: []const f64, out: []f64, lo: usize, hi: usize) void {
    for (lo..hi) |i| {
        var sum: f64 = 0;
        for (v, 0..) |x, j| sum += evalA(j, i) * x;
        out[i] = sum;
    }
}

// Split the rows over `threads` workers; the calling thread takes the first chunk.
fn parallel(comptime f: fn ([]const f64, []f64, usize, usize) void, threads: usize, v: []const f64, out: []f64) !void {
    const n = out.len;
    const chunk = (n + threads - 1) / threads;
    var handles: [256]std.Thread = undefined;
    var count: usize = 0;
    var lo: usize = chunk;
    while (lo < n and count < handles.len) : (lo += chunk) {
        handles[count] = try std.Thread.spawn(.{}, f, .{ v, out, lo, @min(n, lo + chunk) });
        count += 1;
    }
    f(v, out, 0, @min(n, chunk));
    for (handles[0..count]) |h| h.join();
}

fn mulAtAv(threads: usize, v: []const f64, out: []f64, tmp: []f64) !void {
    try parallel(rowsAv, threads, v, tmp);
    try parallel(rowsAtv, threads, tmp, out);
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 100;
    const threads: usize = @min(256, try std.Thread.getCpuCount());
    const u = try arena.alloc(f64, n);
    const v = try arena.alloc(f64, n);
    const tmp = try arena.alloc(f64, n);
    @memset(u, 1.0);
    for (0..10) |_| {
        try mulAtAv(threads, u, v, tmp);
        try mulAtAv(threads, v, u, tmp);
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
