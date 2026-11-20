// mandelbrot, Zig
const std = @import("std");
const Io = std.Io;

fn rowBits(n: usize, y: usize, row: []u8) void {
    const nf: f64 = @floatFromInt(n);
    const ci = 2.0 * @as(f64, @floatFromInt(y)) / nf - 1.0;
    for (0..n) |x| {
        const cr = 2.0 * @as(f64, @floatFromInt(x)) / nf - 1.5;
        var zr: f64 = 0;
        var zi: f64 = 0;
        var tr: f64 = 0;
        var ti: f64 = 0;
        var i: u32 = 0;
        while (i < 50 and tr + ti <= 4.0) : (i += 1) {
            zi = 2.0 * zr * zi + ci;
            zr = tr - ti + cr;
            tr = zr * zr;
            ti = zi * zi;
        }
        if (tr + ti <= 4.0) row[x >> 3] |= @as(u8, 0x80) >> @intCast(x & 7);
    }
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 200;
    const rb = (n + 7) / 8;
    var buf: [1 << 16]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("P4\n{d} {d}\n", .{ n, n });
    const row = try arena.alloc(u8, rb);
    for (0..n) |y| {
        @memset(row, 0);
        rowBits(n, y, row);
        try out.writeAll(row);
    }
    try out.flush();
}
