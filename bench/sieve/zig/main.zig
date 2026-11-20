// sieve - Sieve of Eratosthenes, Zig
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 1000000;
    const composite = try init.gpa.alloc(bool, n + 1);
    defer init.gpa.free(composite);
    @memset(composite, false);
    var i: usize = 2;
    while (i * i <= n) : (i += 1) {
        if (!composite[i]) {
            var j = i * i;
            while (j <= n) : (j += i) composite[j] = true;
        }
    }
    var count: usize = 0;
    i = 2;
    while (i <= n) : (i += 1) {
        if (!composite[i]) count += 1;
    }
    var buf: [64]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("{d}\n", .{count});
    try out.flush();
}
