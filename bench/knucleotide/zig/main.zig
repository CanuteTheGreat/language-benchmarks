// knucleotide - Zig
const std = @import("std");
const Io = std.Io;

const letters = "ACGT";
const Counts = std.AutoHashMap(u64, u32);

fn count(gpa: std.mem.Allocator, s: []const u8, k: usize) !Counts {
    var m = Counts.init(gpa);
    const mask: u64 = (@as(u64, 1) << @intCast(2 * k)) - 1;
    var key: u64 = 0;
    for (s, 0..) |c, i| {
        key = ((key << 2) | c) & mask;
        if (i + 1 >= k) {
            const e = try m.getOrPut(key);
            if (!e.found_existing) e.value_ptr.* = 0;
            e.value_ptr.* += 1;
        }
    }
    return m;
}

const Entry = struct { key: u64, cnt: u32 };

fn lessThan(_: void, a: Entry, b: Entry) bool {
    if (a.cnt != b.cnt) return a.cnt > b.cnt;
    return a.key < b.key;
}

fn frequencies(gpa: std.mem.Allocator, out: *Io.Writer, s: []const u8, k: usize) !void {
    var m = try count(gpa, s, k);
    defer m.deinit();
    var v: std.ArrayList(Entry) = .empty;
    defer v.deinit(gpa);
    var it = m.iterator();
    while (it.next()) |e| try v.append(gpa, .{ .key = e.key_ptr.*, .cnt = e.value_ptr.* });
    std.mem.sort(Entry, v.items, {}, lessThan);
    const total: f64 = @floatFromInt(s.len - k + 1);
    for (v.items) |e| {
        var name: [32]u8 = undefined;
        for (0..k) |j| name[j] = letters[(e.key >> @intCast(2 * (k - 1 - j))) & 3];
        const pct = 100.0 * @as(f64, @floatFromInt(e.cnt)) / total;
        try out.print("{s} {d:.3}\n", .{ name[0..k], pct });
    }
    try out.writeAll("\n");
}

fn occurrences(gpa: std.mem.Allocator, out: *Io.Writer, s: []const u8, seq: []const u8) !void {
    var key: u64 = 0;
    for (seq) |c| key = (key << 2) | std.mem.indexOfScalar(u8, letters, c).?;
    var m = try count(gpa, s, seq.len);
    defer m.deinit();
    try out.print("{d}\t{s}\n", .{ m.get(key) orelse 0, seq });
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    var rbuf: [65536]u8 = undefined;
    var fr: Io.File.Reader = .initStreaming(.stdin(), init.io, &rbuf);
    const data = try fr.interface.allocRemaining(gpa, .unlimited);
    defer gpa.free(data);

    var s: std.ArrayList(u8) = .empty;
    defer s.deinit(gpa);
    var three = false;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len > 0 and line[0] == '>') {
            three = std.mem.startsWith(u8, line, ">THREE");
        } else if (three) {
            for (line) |c| {
                switch (c & 0xDF) {
                    'A' => try s.append(gpa, 0),
                    'C' => try s.append(gpa, 1),
                    'G' => try s.append(gpa, 2),
                    'T' => try s.append(gpa, 3),
                    else => {},
                }
            }
        }
    }

    var obuf: [4096]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &obuf);
    const out = &fw.interface;
    try frequencies(gpa, out, s.items, 1);
    try frequencies(gpa, out, s.items, 2);
    for ([_][]const u8{ "GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT" }) |q| {
        try occurrences(gpa, out, s.items, q);
    }
    try out.flush();
}
