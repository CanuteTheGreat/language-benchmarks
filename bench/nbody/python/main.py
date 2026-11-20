# nbody benchmark, Python
import sys
from math import pi, sqrt

SOLAR_MASS = 4 * pi * pi
DAYS_PER_YEAR = 365.24


def planet(x, y, z, vx, vy, vz, m):
    return [x, y, z, vx * DAYS_PER_YEAR, vy * DAYS_PER_YEAR, vz * DAYS_PER_YEAR, m * SOLAR_MASS]


# each body: [x, y, z, vx, vy, vz, mass]
BODIES = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS],
    planet(4.84143144246472090e+00, -1.16032004402742839e+00, -1.03622044471123109e-01, 1.66007664274403694e-03, 7.69901118419740425e-03, -6.90460016972063023e-05, 9.54791938424326609e-04),
    planet(8.34336671824457987e+00, 4.12479856412430479e+00, -4.03523417114321381e-01, -2.76742510726862411e-03, 4.99852801234917238e-03, 2.30417297573763929e-05, 2.85885980666130812e-04),
    planet(1.28943695621391310e+01, -1.51111514016986312e+01, -2.23307578892655734e-01, 2.96460137564761618e-03, 2.37847173959480950e-03, -2.96589568540237556e-05, 4.36624404335156298e-05),
    planet(1.53796971148509165e+01, -2.59193146099879641e+01, 1.79258772950371181e-01, 2.68067772490389322e-03, 1.62824170038242295e-03, -9.51592254519715870e-05, 5.15138902046611451e-05),
]


def offset_momentum(bodies):
    px = py = pz = 0.0
    for b in bodies:
        px += b[3] * b[6]
        py += b[4] * b[6]
        pz += b[5] * b[6]
    bodies[0][3] = -px / SOLAR_MASS
    bodies[0][4] = -py / SOLAR_MASS
    bodies[0][5] = -pz / SOLAR_MASS


def advance(bodies, dt):
    n = len(bodies)
    for i in range(n):
        a = bodies[i]
        for j in range(i + 1, n):
            b = bodies[j]
            dx = a[0] - b[0]
            dy = a[1] - b[1]
            dz = a[2] - b[2]
            d2 = dx * dx + dy * dy + dz * dz
            mag = dt / (d2 * sqrt(d2))
            a[3] -= dx * b[6] * mag
            a[4] -= dy * b[6] * mag
            a[5] -= dz * b[6] * mag
            b[3] += dx * a[6] * mag
            b[4] += dy * a[6] * mag
            b[5] += dz * a[6] * mag
    for b in bodies:
        b[0] += dt * b[3]
        b[1] += dt * b[4]
        b[2] += dt * b[5]


def energy(bodies):
    e = 0.0
    n = len(bodies)
    for i in range(n):
        a = bodies[i]
        e += 0.5 * a[6] * (a[3] * a[3] + a[4] * a[4] + a[5] * a[5])
        for j in range(i + 1, n):
            b = bodies[j]
            dx = a[0] - b[0]
            dy = a[1] - b[1]
            dz = a[2] - b[2]
            e -= a[6] * b[6] / sqrt(dx * dx + dy * dy + dz * dz)
    return e


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    offset_momentum(BODIES)
    print("%.9f" % energy(BODIES))
    for _ in range(n):
        advance(BODIES, 0.01)
    print("%.9f" % energy(BODIES))


main()
