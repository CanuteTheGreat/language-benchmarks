// nbody benchmark, Rust
const PI: f64 = 3.141592653589793;
const SOLAR_MASS: f64 = 4.0 * PI * PI;
const DAYS_PER_YEAR: f64 = 365.24;

#[derive(Clone, Copy)]
struct Body {
    pos: [f64; 3],
    vel: [f64; 3],
    mass: f64,
}

fn body(pos: [f64; 3], vel: [f64; 3], mass: f64) -> Body {
    Body {
        pos,
        vel: [vel[0] * DAYS_PER_YEAR, vel[1] * DAYS_PER_YEAR, vel[2] * DAYS_PER_YEAR],
        mass: mass * SOLAR_MASS,
    }
}

fn offset_momentum(bodies: &mut [Body]) {
    let mut p = [0.0; 3];
    for b in bodies.iter() {
        for k in 0..3 {
            p[k] += b.vel[k] * b.mass;
        }
    }
    for k in 0..3 {
        bodies[0].vel[k] = -p[k] / SOLAR_MASS;
    }
}

fn advance(bodies: &mut [Body], dt: f64) {
    let n = bodies.len();
    for i in 0..n {
        let (head, tail) = bodies.split_at_mut(i + 1);
        let a = &mut head[i];
        for b in tail.iter_mut() {
            let dx = a.pos[0] - b.pos[0];
            let dy = a.pos[1] - b.pos[1];
            let dz = a.pos[2] - b.pos[2];
            let d2 = dx * dx + dy * dy + dz * dz;
            let mag = dt / (d2 * d2.sqrt());
            a.vel[0] -= dx * b.mass * mag;
            a.vel[1] -= dy * b.mass * mag;
            a.vel[2] -= dz * b.mass * mag;
            b.vel[0] += dx * a.mass * mag;
            b.vel[1] += dy * a.mass * mag;
            b.vel[2] += dz * a.mass * mag;
        }
    }
    for b in bodies.iter_mut() {
        for k in 0..3 {
            b.pos[k] += dt * b.vel[k];
        }
    }
}

fn energy(bodies: &[Body]) -> f64 {
    let mut e = 0.0;
    for (i, a) in bodies.iter().enumerate() {
        e += 0.5 * a.mass * (a.vel[0] * a.vel[0] + a.vel[1] * a.vel[1] + a.vel[2] * a.vel[2]);
        for b in &bodies[i + 1..] {
            let dx = a.pos[0] - b.pos[0];
            let dy = a.pos[1] - b.pos[1];
            let dz = a.pos[2] - b.pos[2];
            e -= a.mass * b.mass / (dx * dx + dy * dy + dz * dz).sqrt();
        }
    }
    e
}

fn main() {
    let n: u32 = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(1000);
    let mut bodies = [
        Body { pos: [0.0; 3], vel: [0.0; 3], mass: SOLAR_MASS },
        body([4.84143144246472090e+00, -1.16032004402742839e+00, -1.03622044471123109e-01],
             [1.66007664274403694e-03, 7.69901118419740425e-03, -6.90460016972063023e-05],
             9.54791938424326609e-04),
        body([8.34336671824457987e+00, 4.12479856412430479e+00, -4.03523417114321381e-01],
             [-2.76742510726862411e-03, 4.99852801234917238e-03, 2.30417297573763929e-05],
             2.85885980666130812e-04),
        body([1.28943695621391310e+01, -1.51111514016986312e+01, -2.23307578892655734e-01],
             [2.96460137564761618e-03, 2.37847173959480950e-03, -2.96589568540237556e-05],
             4.36624404335156298e-05),
        body([1.53796971148509165e+01, -2.59193146099879641e+01, 1.79258772950371181e-01],
             [2.68067772490389322e-03, 1.62824170038242295e-03, -9.51592254519715870e-05],
             5.15138902046611451e-05),
    ];
    offset_momentum(&mut bodies);
    println!("{:.9}", energy(&bodies));
    for _ in 0..n {
        advance(&mut bodies, 0.01);
    }
    println!("{:.9}", energy(&bodies));
}
