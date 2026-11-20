const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    var buf: [1024]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    try out.print("Hello, world!\n", .{});
    try out.flush();
}
