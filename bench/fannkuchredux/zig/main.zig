// fannkuchredux, Zig
const std = @import("std");
const Io = std.Io;

const max_n = 16;

const Result = struct { sum: i64, max_flips: i32 };

// Process permutations with index in [start, end).
fn work(n: usize, fact: []const usize, start: usize, end: usize) Result {
    var p: [max_n]usize = undefined;
    var pp: [max_n]usize = undefined;
    var q: [max_n]usize = undefined;
    var count: [max_n]usize = @splat(0);
    var idx = start;
    for (0..n) |i| p[i] = i;
    var i: usize = n - 1;
    while (i > 0) : (i -= 1) {
        const d = idx / fact[i];
        idx %= fact[i];
        count[i] = d;
        pp = p;
        for (0..i + 1) |j| p[j] = if (j + d <= i) pp[j + d] else pp[j + d - i - 1];
    }
    var sum: i64 = 0;
    var max_flips: i32 = 0;
    var k = start;
    while (k < end) : (k += 1) {
        if (k > start) {
            var first = p[1];
            p[1] = p[0];
            p[0] = first;
            var r: usize = 1;
            while (true) {
                count[r] += 1;
                if (count[r] <= r) break;
                count[r] = 0;
                r += 1;
                const next = p[1];
                p[0] = next;
                for (1..r) |j| p[j] = p[j + 1];
                p[r] = first;
                first = next;
            }
        }
        q = p;
        var flips: i32 = 0;
        while (q[0] != 0) {
            std.mem.reverse(usize, q[0 .. q[0] + 1]);
            flips += 1;
        }
        max_flips = @max(max_flips, flips);
        sum += if (k % 2 == 0) flips else -flips;
    }
    return .{ .sum = sum, .max_flips = max_flips };
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 7;
    var fact: [max_n + 1]usize = undefined;
    fact[0] = 1;
    for (1..n + 1) |i| fact[i] = fact[i - 1] * i;
    const r = work(n, &fact, 0, fact[n]);

    var buf: [256]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\nPfannkuchen({d}) = {d}\n", .{ r.sum, n, r.max_flips });
    try out.flush();
}
