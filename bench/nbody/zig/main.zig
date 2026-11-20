// nbody benchmark, Zig
const std = @import("std");
const Io = std.Io;

const pi = 3.141592653589793;
const solar_mass = 4.0 * pi * pi;
const days_per_year = 365.24;

const Body = struct { x: f64, y: f64, z: f64, vx: f64, vy: f64, vz: f64, mass: f64 };

fn planet(x: f64, y: f64, z: f64, vx: f64, vy: f64, vz: f64, m: f64) Body {
    return .{ .x = x, .y = y, .z = z, .vx = vx * days_per_year, .vy = vy * days_per_year, .vz = vz * days_per_year, .mass = m * solar_mass };
}

var bodies = [5]Body{
    .{ .x = 0, .y = 0, .z = 0, .vx = 0, .vy = 0, .vz = 0, .mass = solar_mass },
    planet(4.84143144246472090e+00, -1.16032004402742839e+00, -1.03622044471123109e-01, 1.66007664274403694e-03, 7.69901118419740425e-03, -6.90460016972063023e-05, 9.54791938424326609e-04),
    planet(8.34336671824457987e+00, 4.12479856412430479e+00, -4.03523417114321381e-01, -2.76742510726862411e-03, 4.99852801234917238e-03, 2.30417297573763929e-05, 2.85885980666130812e-04),
    planet(1.28943695621391310e+01, -1.51111514016986312e+01, -2.23307578892655734e-01, 2.96460137564761618e-03, 2.37847173959480950e-03, -2.96589568540237556e-05, 4.36624404335156298e-05),
    planet(1.53796971148509165e+01, -2.59193146099879641e+01, 1.79258772950371181e-01, 2.68067772490389322e-03, 1.62824170038242295e-03, -9.51592254519715870e-05, 5.15138902046611451e-05),
};

fn offsetMomentum() void {
    var px: f64 = 0;
    var py: f64 = 0;
    var pz: f64 = 0;
    for (bodies) |b| {
        px += b.vx * b.mass;
        py += b.vy * b.mass;
        pz += b.vz * b.mass;
    }
    bodies[0].vx = -px / solar_mass;
    bodies[0].vy = -py / solar_mass;
    bodies[0].vz = -pz / solar_mass;
}

fn advance(dt: f64) void {
    for (0..bodies.len) |i| {
        const a = &bodies[i];
        for (i + 1..bodies.len) |j| {
            const b = &bodies[j];
            const dx = a.x - b.x;
            const dy = a.y - b.y;
            const dz = a.z - b.z;
            const d2 = dx * dx + dy * dy + dz * dz;
            const mag = dt / (d2 * @sqrt(d2));
            a.vx -= dx * b.mass * mag;
            a.vy -= dy * b.mass * mag;
            a.vz -= dz * b.mass * mag;
            b.vx += dx * a.mass * mag;
            b.vy += dy * a.mass * mag;
            b.vz += dz * a.mass * mag;
        }
    }
    for (&bodies) |*b| {
        b.x += dt * b.vx;
        b.y += dt * b.vy;
        b.z += dt * b.vz;
    }
}

fn energy() f64 {
    var e: f64 = 0;
    for (0..bodies.len) |i| {
        const a = bodies[i];
        e += 0.5 * a.mass * (a.vx * a.vx + a.vy * a.vy + a.vz * a.vz);
        for (i + 1..bodies.len) |j| {
            const b = bodies[j];
            const dx = a.x - b.x;
            const dy = a.y - b.y;
            const dz = a.z - b.z;
            e -= a.mass * b.mass / @sqrt(dx * dx + dy * dy + dz * dz);
        }
    }
    return e;
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const n: u32 = if (args.len > 1) try std.fmt.parseInt(u32, args[1], 10) else 1000;
    var buf: [256]u8 = undefined;
    var fw: Io.File.Writer = .init(.stdout(), init.io, &buf);
    const out = &fw.interface;
    offsetMomentum();
    try out.print("{d:.9}\n", .{energy()});
    for (0..n) |_| advance(0.01);
    try out.print("{d:.9}\n", .{energy()});
    try out.flush();
}
