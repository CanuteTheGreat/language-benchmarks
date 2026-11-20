// dijkstra - minstd graph, ArrayList adjacency, std.PriorityQueue, Zig.
const std = @import("std");
const Io = std.Io;

const Edge = struct { to: u32, w: u32 };
const Item = struct { d: u64, v: u32 };

fn lessThan(_: void, a: Item, b: Item) std.math.Order {
    return std.math.order(a.d, b.d);
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const gpa = init.gpa;
    const args = try init.minimal.args.toSlice(arena);
    const nv: usize = if (args.len > 2) try std.fmt.parseInt(usize, args[1], 10) else 1000;
    const ne: usize = if (args.len > 2) try std.fmt.parseInt(usize, args[2], 10) else 5000;

    const adj = try gpa.alloc(std.ArrayList(Edge), nv);
    for (adj) |*l| l.* = .empty;
    var g: u64 = 42;
    for (0..ne) |_| {
        g = g * 48271 % 2147483647;
        const u = g % nv;
        g = g * 48271 % 2147483647;
        const v = g % nv;
        g = g * 48271 % 2147483647;
        const w = g % 100 + 1;
        try adj[u].append(gpa, .{ .to = @intCast(v), .w = @intCast(w) });
    }

    const inf = std.math.maxInt(u64);
    const dist = try gpa.alloc(u64, nv);
    @memset(dist, inf);
    var pq = std.PriorityQueue(Item, void, lessThan).initContext({});
    dist[0] = 0;
    try pq.push(gpa, .{ .d = 0, .v = 0 });
    while (pq.pop()) |it| {
        if (it.d > dist[it.v]) continue;
        for (adj[it.v].items) |e| {
            const nd = it.d + e.w;
            if (nd < dist[e.to]) {
                dist[e.to] = nd;
                try pq.push(gpa, .{ .d = nd, .v = e.to });
            }
        }
    }
    var reached: u64 = 0;
    var sum: u64 = 0;
    var max: u64 = 0;
    for (dist) |d| {
        if (d != inf) {
            reached += 1;
            sum += d;
            max = @max(max, d);
        }
    }

    var buf: [128]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d} {d}\n", .{ reached, sum, max });
    try out.flush();
}
