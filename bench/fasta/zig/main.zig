// fasta - Zig
const std = @import("std");
const Io = std.Io;

const LINE = 60;
const IM: u32 = 139968;
const IA: u32 = 3877;
const IC: u32 = 29573;

var last: u32 = 42;

fn rnd(max: f64) f64 {
    last = (last * IA + IC) % IM;
    return max * @as(f64, @floatFromInt(last)) / @as(f64, @floatFromInt(IM));
}

const AminoAcid = struct { c: u8, p: f64 };

const alu =
    "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG" ++
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" ++
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT" ++
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" ++
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG" ++
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" ++
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

fn repeatFasta(out: *Io.Writer, s: []const u8, total: usize) !void {
    var n = total;
    var pos: usize = 0;
    var line: [LINE + 1]u8 = undefined;
    while (n > 0) {
        const m = @min(n, LINE);
        for (0..m) |i| {
            line[i] = s[pos];
            pos += 1;
            if (pos == s.len) pos = 0;
        }
        line[m] = '\n';
        try out.writeAll(line[0 .. m + 1]);
        n -= m;
    }
}

fn randomFasta(out: *Io.Writer, genes: []AminoAcid, total: usize) !void {
    var cum: f64 = 0;
    for (genes) |*g| {
        cum += g.p;
        g.p = cum;
    }
    var n = total;
    var line: [LINE + 1]u8 = undefined;
    while (n > 0) {
        const m = @min(n, LINE);
        for (0..m) |i| {
            const r = rnd(1.0);
            var k: usize = 0;
            while (k < genes.len - 1 and r >= genes[k].p) k += 1;
            line[i] = genes[k].c;
        }
        line[m] = '\n';
        try out.writeAll(line[0 .. m + 1]);
        n -= m;
    }
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 1000;

    var buf: [1 << 16]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;

    var iub = [_]AminoAcid{
        .{ .c = 'a', .p = 0.27 }, .{ .c = 'c', .p = 0.12 }, .{ .c = 'g', .p = 0.12 }, .{ .c = 't', .p = 0.27 },
        .{ .c = 'B', .p = 0.02 }, .{ .c = 'D', .p = 0.02 }, .{ .c = 'H', .p = 0.02 }, .{ .c = 'K', .p = 0.02 },
        .{ .c = 'M', .p = 0.02 }, .{ .c = 'N', .p = 0.02 }, .{ .c = 'R', .p = 0.02 }, .{ .c = 'S', .p = 0.02 },
        .{ .c = 'V', .p = 0.02 }, .{ .c = 'W', .p = 0.02 }, .{ .c = 'Y', .p = 0.02 },
    };
    var homosapiens = [_]AminoAcid{
        .{ .c = 'a', .p = 0.3029549426680 },
        .{ .c = 'c', .p = 0.1979883004921 },
        .{ .c = 'g', .p = 0.1975473066391 },
        .{ .c = 't', .p = 0.3015094502008 },
    };

    try out.writeAll(">ONE Homo sapiens alu\n");
    try repeatFasta(out, alu, n * 2);
    try out.writeAll(">TWO IUB ambiguity codes\n");
    try randomFasta(out, &iub, n * 3);
    try out.writeAll(">THREE Homo sapiens frequency\n");
    try randomFasta(out, &homosapiens, n * 5);
    try out.flush();
}
