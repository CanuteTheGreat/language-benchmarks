// regexredux - Zig (PCRE2 through the C ABI; Zig 0.17 has no @cImport, so the few
// functions used are declared by hand and linked with -lpcre2-8)
const std = @import("std");
const Io = std.Io;

const c = struct {
    const PCRE2_SIZE = usize;
    const PCRE2_JIT_COMPLETE: u32 = 1;
    const pcre2_code_8 = opaque {};
    const pcre2_match_data_8 = opaque {};
    extern fn pcre2_compile_8(pattern: [*]const u8, length: usize, options: u32, errorcode: *c_int, erroroffset: *usize, ccontext: ?*anyopaque) ?*pcre2_code_8;
    extern fn pcre2_jit_compile_8(code: *pcre2_code_8, options: u32) c_int;
    extern fn pcre2_code_free_8(code: *pcre2_code_8) void;
    extern fn pcre2_match_data_create_from_pattern_8(code: *const pcre2_code_8, gcontext: ?*anyopaque) ?*pcre2_match_data_8;
    extern fn pcre2_match_data_free_8(md: *pcre2_match_data_8) void;
    extern fn pcre2_match_8(code: *const pcre2_code_8, subject: [*]const u8, length: usize, startoffset: usize, options: u32, md: *pcre2_match_data_8, mcontext: ?*anyopaque) c_int;
    extern fn pcre2_get_ovector_pointer_8(md: *pcre2_match_data_8) [*]usize;
};

fn compile(pat: []const u8) *c.pcre2_code_8 {
    var err: c_int = 0;
    var off: c.PCRE2_SIZE = 0;
    const re = c.pcre2_compile_8(pat.ptr, pat.len, 0, &err, &off, null) orelse
        @panic("bad pattern");
    _ = c.pcre2_jit_compile_8(re, c.PCRE2_JIT_COMPLETE);
    return re;
}

fn count(re: *c.pcre2_code_8, s: []const u8) usize {
    const md = c.pcre2_match_data_create_from_pattern_8(re, null).?;
    defer c.pcre2_match_data_free_8(md);
    var n: usize = 0;
    var start: usize = 0;
    while (start <= s.len and c.pcre2_match_8(re, s.ptr, s.len, start, 0, md, null) >= 0) {
        const ov = c.pcre2_get_ovector_pointer_8(md);
        n += 1;
        start = if (ov[1] > ov[0]) ov[1] else ov[1] + 1;
    }
    return n;
}

/// Replace every match of pat in s with rep; returns a new owned buffer.
fn replace(gpa: std.mem.Allocator, pat: []const u8, s: []const u8, rep: []const u8) ![]u8 {
    const re = compile(pat);
    defer c.pcre2_code_free_8(re);
    const md = c.pcre2_match_data_create_from_pattern_8(re, null).?;
    defer c.pcre2_match_data_free_8(md);
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(gpa);
    try out.ensureTotalCapacity(gpa, s.len);
    var last: usize = 0;
    var start: usize = 0;
    while (start <= s.len and c.pcre2_match_8(re, s.ptr, s.len, start, 0, md, null) >= 0) {
        const ov = c.pcre2_get_ovector_pointer_8(md);
        try out.appendSlice(gpa, s[last..ov[0]]);
        try out.appendSlice(gpa, rep);
        last = ov[1];
        start = if (ov[1] > ov[0]) ov[1] else ov[1] + 1;
    }
    try out.appendSlice(gpa, s[last..]);
    return out.toOwnedSlice(gpa);
}

const variants = [_][]const u8{
    "agggtaaa|tttaccct",
    "[cgt]gggtaaa|tttaccc[acg]",
    "a[act]ggtaaa|tttacc[agt]t",
    "ag[act]gtaaa|tttac[agt]ct",
    "agg[act]taaa|ttta[agt]cct",
    "aggg[acg]aaa|ttt[cgt]ccct",
    "agggt[cgt]aa|tt[acg]accct",
    "agggta[cgt]a|t[acg]taccct",
    "agggtaa[cgt]|[acg]ttaccct",
};

const subs = [_][2][]const u8{
    .{ "tHa[Nt]", "<4>" },
    .{ "aND|caN|Ha[DS]|WaS", "<3>" },
    .{ "a[NSt]|BY", "<2>" },
    .{ "<[^>]*>", "|" },
    .{ "\\|[^|][^|]*\\|", "-" },
};

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    var rbuf: [65536]u8 = undefined;
    var fr: Io.File.Reader = .initStreaming(.stdin(), init.io, &rbuf);
    const input = try fr.interface.allocRemaining(gpa, .unlimited);
    const len0 = input.len;
    var seq = try replace(gpa, ">.*\n|\n", input, "");
    gpa.free(input);
    const len1 = seq.len;

    var obuf: [4096]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &obuf);
    const out = &fw.interface;

    for (variants) |v| {
        const re = compile(v);
        try out.print("{s} {d}\n", .{ v, count(re, seq) });
        c.pcre2_code_free_8(re);
    }
    for (subs) |sub| {
        const next = try replace(gpa, sub[0], seq, sub[1]);
        gpa.free(seq);
        seq = next;
    }
    try out.print("\n{d}\n{d}\n{d}\n", .{ len0, len1, seq.len });
    try out.flush();
}
