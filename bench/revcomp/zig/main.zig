// revcomp - Zig
const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    var comp: [256]u8 = undefined;
    for (&comp, 0..) |*c, i| c.* = @intCast(i);
    const from = "ACGTUMRWSYKVHDBN";
    const to = "TGCAAKYWSRMBDHVN";
    for (from, to) |f, t| {
        comp[f] = t;
        comp[f | 0x20] = t;
    }

    var rbuf: [65536]u8 = undefined;
    var fr: Io.File.Reader = .initStreaming(.stdin(), init.io, &rbuf);
    const data = try fr.interface.allocRemaining(gpa, .unlimited);
    defer gpa.free(data);

    var obuf: [65536]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &obuf);
    const out = &fw.interface;

    var seq: std.ArrayList(u8) = .empty;
    defer seq.deinit(gpa);
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len > 0 and line[0] == '>') {
            try emit(out, seq.items, &comp);
            seq.clearRetainingCapacity();
            try out.writeAll(line);
            try out.writeAll("\n");
        } else {
            try seq.appendSlice(gpa, line);
        }
    }
    try emit(out, seq.items, &comp);
    try out.flush();
}

// Write the reverse complement of seq in lines of 60.
fn emit(out: *Io.Writer, seq: []const u8, comp: *const [256]u8) !void {
    var line: [61]u8 = undefined;
    var n = seq.len;
    while (n > 0) {
        const m = @min(n, 60);
        for (0..m) |j| {
            n -= 1;
            line[j] = comp[seq[n]];
        }
        line[m] = '\n';
        try out.writeAll(line[0 .. m + 1]);
    }
}
