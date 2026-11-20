// fannkuchredux, Zig, multi-threaded (std.Thread)
const std = @import("std");
const Io = std.Io;

const max_n = 16;

const Result = struct { sum: i64 = 0, max_flips: i32 = 0 };

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

const Shared = struct {
    n: usize,
    fact: []const usize,
    total: usize,
    nchunks: usize,
    size: usize,
    next_chunk: std.atomic.Value(usize) = .init(0),
};

fn worker(sh: *Shared, res: *Result) void {
    while (true) {
        const c = sh.next_chunk.fetchAdd(1, .monotonic);
        if (c >= sh.nchunks) return;
        const s = c * sh.size;
        const e = @min(sh.total, s + sh.size);
        if (s >= e) continue;
        const r = work(sh.n, sh.fact, s, e);
        res.sum += r.sum;
        res.max_flips = @max(res.max_flips, r.max_flips);
    }
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 7;
    var fact: [max_n + 1]usize = undefined;
    fact[0] = 1;
    for (1..n + 1) |i| fact[i] = fact[i - 1] * i;

    const total = fact[n];
    const nthreads = try std.Thread.getCpuCount();
    const nchunks = @min(total, nthreads * 16);
    var sh: Shared = .{
        .n = n,
        .fact = &fact,
        .total = total,
        .nchunks = nchunks,
        .size = (total + nchunks - 1) / nchunks,
    };
    const results = try arena.alloc(Result, nthreads);
    @memset(results, .{});
    const threads = try arena.alloc(std.Thread, nthreads);
    for (threads, results) |*t, *r| t.* = try std.Thread.spawn(.{}, worker, .{ &sh, r });
    for (threads) |t| t.join();

    var chk: i64 = 0;
    var mx: i32 = 0;
    for (results) |r| {
        chk += r.sum;
        mx = @max(mx, r.max_flips);
    }
    var buf: [256]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\nPfannkuchen({d}) = {d}\n", .{ chk, n, mx });
    try out.flush();
}
