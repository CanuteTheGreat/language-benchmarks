// sortstd - minstd data, std.mem.sort, Zig.
const std = @import("std");
const Io = std.Io;

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
    std.mem.sort(i32, a, {}, std.sort.asc(i32));
    for (1..n) |i| if (a[i - 1] > a[i]) std.process.exit(1);

    var buf: [128]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d} {d} {d}\n", .{ a[0], a[n / 2], a[n - 1] });
    try out.flush();
}
