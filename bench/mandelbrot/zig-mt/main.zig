// mandelbrot, Zig, multi-threaded (std.Thread)
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

const Job = struct {
    n: usize,
    rb: usize,
    img: []u8,
    next: std.atomic.Value(usize) = .init(0),
};

fn worker(job: *Job) void {
    while (true) {
        const y = job.next.fetchAdd(1, .monotonic);
        if (y >= job.n) return;
        rowBits(job.n, y, job.img[y * job.rb ..][0..job.rb]);
    }
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 200;
    const rb = (n + 7) / 8;
    const img = try arena.alloc(u8, rb * n);
    @memset(img, 0);
    var job: Job = .{ .n = n, .rb = rb, .img = img };
    const ncpu = try std.Thread.getCpuCount();
    const threads = try arena.alloc(std.Thread, ncpu);
    for (threads) |*t| t.* = try std.Thread.spawn(.{}, worker, .{&job});
    for (threads) |t| t.join();
    var buf: [1 << 16]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("P4\n{d} {d}\n", .{ n, n });
    try out.writeAll(img);
    try out.flush();
}
