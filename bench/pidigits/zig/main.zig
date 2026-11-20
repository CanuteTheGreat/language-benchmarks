// pidigits - Benchmarks Game spigot with std.math.big.int, Zig.
const std = @import("std");
const Io = std.Io;
const big = std.math.big.int;

const Spigot = struct {
    numer: big.Managed,
    accum: big.Managed,
    denom: big.Managed,
    t1: big.Managed,
    t2: big.Managed,
    q: big.Managed,
    r: big.Managed,

    fn extractDigit(s: *Spigot, nth: u64) !u64 {
        try s.t1.set(nth);
        try s.t1.mul(&s.numer, &s.t1);
        try s.t1.add(&s.t1, &s.accum);
        try s.q.divTrunc(&s.r, &s.t1, &s.denom);
        return s.q.toInt(u64);
    }

    fn nextTerm(s: *Spigot, k: u64) !void {
        const y2 = k * 2 + 1;
        try s.t1.set(2);
        try s.t1.mul(&s.numer, &s.t1);
        try s.accum.add(&s.accum, &s.t1);
        try s.t2.set(y2);
        try s.accum.mul(&s.accum, &s.t2);
        try s.t1.set(k);
        try s.numer.mul(&s.numer, &s.t1);
        try s.denom.mul(&s.denom, &s.t2);
    }

    fn eliminateDigit(s: *Spigot, d: u64) !void {
        try s.t1.set(d);
        try s.t1.mul(&s.denom, &s.t1);
        try s.accum.sub(&s.accum, &s.t1);
        try s.t1.set(10);
        try s.accum.mul(&s.accum, &s.t1);
        try s.numer.mul(&s.numer, &s.t1);
    }
};

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const n: usize = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 30;

    var s: Spigot = .{
        .numer = try big.Managed.initSet(gpa, 1),
        .accum = try big.Managed.initSet(gpa, 0),
        .denom = try big.Managed.initSet(gpa, 1),
        .t1 = try big.Managed.init(gpa),
        .t2 = try big.Managed.init(gpa),
        .q = try big.Managed.init(gpa),
        .r = try big.Managed.init(gpa),
    };

    var buf: [4096]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;

    var i: usize = 0;
    var k: u64 = 0;
    while (i < n) {
        k += 1;
        try s.nextTerm(k);
        if (s.numer.order(s.accum) == .gt) continue;
        const d = try s.extractDigit(3);
        if (d != try s.extractDigit(4)) continue;
        try out.writeByte(@intCast('0' + d));
        i += 1;
        if (i % 10 == 0) try out.print("\t:{d}\n", .{i});
        try s.eliminateDigit(d);
    }
    if (n % 10 != 0) {
        try out.splatByteAll(' ', 10 - n % 10);
        try out.print("\t:{d}\n", .{n});
    }
    try out.flush();
}
