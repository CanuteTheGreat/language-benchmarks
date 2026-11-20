// levenshtein - Zig
const std = @import("std");
const Io = std.Io;

var state: u64 = 42;

fn next() u64 {
    state = (state * 48271) % 2147483647;
    return state;
}

fn makeString(a: std.mem.Allocator, len: usize) ![]u8 {
    const s = try a.alloc(u8, len);
    for (s) |*c| c.* = "ACGT"[next() % 4];
    return s;
}

pub fn main(init: std.process.Init) !void {
    const a = init.gpa;
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const len: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 300;

    const s = try makeString(a, len);
    defer a.free(s);
    const t = try makeString(a, len);
    defer a.free(t);

    var prev = try a.alloc(u32, len + 1);
    defer a.free(prev);
    var cur = try a.alloc(u32, len + 1);
    defer a.free(cur);
    for (prev, 0..) |*p, j| p.* = @intCast(j);
    for (1..len + 1) |i| {
        cur[0] = @intCast(i);
        for (1..len + 1) |j| {
            const sub = prev[j - 1] + @intFromBool(s[i - 1] != t[j - 1]);
            cur[j] = @min(sub, prev[j] + 1, cur[j - 1] + 1);
        }
        std.mem.swap([]u32, &prev, &cur);
    }

    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\n", .{prev[len]});
    try out.flush();
}
