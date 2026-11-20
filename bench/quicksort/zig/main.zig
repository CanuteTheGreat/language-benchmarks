// quicksort - minstd data, hand-written quicksort, Zig.
const std = @import("std");
const Io = std.Io;

fn insertion(a: []i32, lo: isize, hi: isize) void {
    var i = lo + 1;
    while (i <= hi) : (i += 1) {
        const v = a[@intCast(i)];
        var j = i - 1;
        while (j >= lo and a[@intCast(j)] > v) : (j -= 1) a[@intCast(j + 1)] = a[@intCast(j)];
        a[@intCast(j + 1)] = v;
    }
}

fn median3(x: i32, y: i32, z: i32) i32 {
    if (x < y) return if (y < z) y else if (x < z) z else x;
    return if (x < z) x else if (y < z) z else y;
}

fn sort(a: []i32, lo_in: isize, hi_in: isize) void {
    var lo = lo_in;
    var hi = hi_in;
    while (hi - lo >= 16) {
        const p = median3(a[@intCast(lo)], a[@intCast(@divTrunc(lo + hi, 2))], a[@intCast(hi)]);
        var i = lo - 1;
        var j = hi + 1;
        while (true) {
            i += 1;
            while (a[@intCast(i)] < p) i += 1;
            j -= 1;
            while (a[@intCast(j)] > p) j -= 1;
            if (i >= j) break;
            std.mem.swap(i32, &a[@intCast(i)], &a[@intCast(j)]);
        }
        if (j - lo < hi - j) {
            sort(a, lo, j);
            lo = j + 1;
        } else {
            sort(a, j + 1, hi);
            hi = j;
        }
    }
    insertion(a, lo, hi);
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 10000;

    const a = try init.gpa.alloc(i32, n);
    defer init.gpa.free(a);
    var state: u64 = 42;
    for (a) |*x| {
        state = state * 48271 % 2147483647;
        x.* = @intCast(state);
    }
    sort(a, 0, @as(isize, @intCast(n)) - 1);
    for (1..n) |i| if (a[i - 1] > a[i]) std.process.exit(1);

    var buf: [128]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d} {d}\n", .{ a[0], a[n / 2], a[n - 1] });
    try out.flush();
}
