// hashmap - minstd keys, std.AutoHashMap, Zig.
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: u64 = if (args.len > 1) try std.fmt.parseInt(u64, args[1], 10) else 10000;

    var map = std.AutoHashMap(u32, u64).init(init.gpa);
    defer map.deinit();
    var s1: u64 = 42;
    var i: u64 = 0;
    while (i < n) : (i += 1) {
        s1 = s1 * 48271 % 2147483647;
        try map.put(@intCast(s1), i);
    }
    var s2: u64 = 42;
    var hits: u64 = 0;
    var sum: u64 = 0;
    var j: u64 = 0;
    while (j < 2 * n) : (j += 1) {
        s2 = s2 * 48271 % 2147483647;
        if (map.get(@intCast(s2))) |v| {
            hits += 1;
            sum += v;
        }
    }

    var buf: [128]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d} {d}\n", .{ map.count(), hits, sum });
    try out.flush();
}
