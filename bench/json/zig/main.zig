// json - parse, walk and re-serialise with std.json
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    if (args.len < 2) return error.MissingPath;

    const text = try Io.Dir.cwd().readFileAlloc(init.io, args[1], gpa, .unlimited);
    defer gpa.free(text);
    const root = try std.json.parseFromSliceLeaky(std.json.Value, arena, text, .{});

    var count: u64 = 0;
    var active: u64 = 0;
    var score: i64 = 0;
    for (root.array.items) |rec| {
        count += 1;
        if (rec.object.get("active")) |a| {
            if (a == .bool and a.bool) active += 1;
        }
        if (rec.object.get("score")) |s| {
            if (s == .integer) score += s.integer;
        }
    }

    const out = try std.json.Stringify.valueAlloc(gpa, root, .{});
    defer gpa.free(out);

    var buf: [256]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const w = &fw.interface;
    try w.print("{d} {d} {d} {d}\n", .{ count, active, score, out.len });
    try w.flush();
}
