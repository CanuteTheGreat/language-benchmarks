// binarytrees - Zig, std.Thread
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const Node = struct { left: ?*Node, right: ?*Node };

fn make(a: Allocator, depth: u32) !*Node {
    const n = try a.create(Node);
    if (depth > 0) {
        n.left = try make(a, depth - 1);
        n.right = try make(a, depth - 1);
    } else {
        n.left = null;
        n.right = null;
    }
    return n;
}

fn check(n: *const Node) u64 {
    if (n.left) |l| return 1 + check(l) + check(n.right.?);
    return 1;
}

fn release(a: Allocator, n: *Node) void {
    if (n.left) |l| {
        release(a, l);
        release(a, n.right.?);
    }
    a.destroy(n);
}

fn worker(a: Allocator, depth: u32, iters: u64, next: *std.atomic.Value(u64), sum: *std.atomic.Value(u64)) void {
    var local: u64 = 0;
    while (next.fetchAdd(1, .monotonic) < iters) {
        const x = make(a, depth) catch @panic("out of memory");
        local += check(x);
        release(a, x);
    }
    _ = sum.fetchAdd(local, .monotonic);
}

pub fn main(init: std.process.Init) !void {
    const a = init.gpa;
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: u32 = if (args.len > 1) try std.fmt.parseInt(u32, args[1], 10) else 10;
    const min_depth: u32 = 4;
    const max_depth: u32 = @max(n, min_depth + 2);
    const stretch = max_depth + 1;
    const nthreads = try std.Thread.getCpuCount();

    var buf: [4096]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;

    const t = try make(a, stretch);
    try out.print("stretch tree of depth {d}\t check: {d}\n", .{ stretch, check(t) });
    release(a, t);

    const long_lived = try make(a, max_depth);
    const threads = try a.alloc(std.Thread, nthreads);
    defer a.free(threads);
    var d = min_depth;
    while (d <= max_depth) : (d += 2) {
        const iters: u64 = @as(u64, 1) << @intCast(max_depth - d + min_depth);
        var next = std.atomic.Value(u64).init(0);
        var sum = std.atomic.Value(u64).init(0);
        for (threads) |*th| th.* = try std.Thread.spawn(.{}, worker, .{ a, d, iters, &next, &sum });
        for (threads) |th| th.join();
        try out.print("{d}\t trees of depth {d}\t check: {d}\n", .{ iters, d, sum.load(.monotonic) });
    }
    try out.print("long lived tree of depth {d}\t check: {d}\n", .{ max_depth, check(long_lived) });
    release(a, long_lived);
    try out.flush();
}
