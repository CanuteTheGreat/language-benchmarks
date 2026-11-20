// nbody benchmark, C#
using System.Globalization;

const double SolarMass = 4 * Math.PI * Math.PI;
const double DaysPerYear = 365.24;

Body Planet(double x, double y, double z, double vx, double vy, double vz, double m) =>
    new Body { X = x, Y = y, Z = z, Vx = vx * DaysPerYear, Vy = vy * DaysPerYear, Vz = vz * DaysPerYear, Mass = m * SolarMass };

var bodies = new Body[]
{
    new Body { Mass = SolarMass },
    Planet(4.84143144246472090e+00, -1.16032004402742839e+00, -1.03622044471123109e-01, 1.66007664274403694e-03, 7.69901118419740425e-03, -6.90460016972063023e-05, 9.54791938424326609e-04),
    Planet(8.34336671824457987e+00, 4.12479856412430479e+00, -4.03523417114321381e-01, -2.76742510726862411e-03, 4.99852801234917238e-03, 2.30417297573763929e-05, 2.85885980666130812e-04),
    Planet(1.28943695621391310e+01, -1.51111514016986312e+01, -2.23307578892655734e-01, 2.96460137564761618e-03, 2.37847173959480950e-03, -2.96589568540237556e-05, 4.36624404335156298e-05),
    Planet(1.53796971148509165e+01, -2.59193146099879641e+01, 1.79258772950371181e-01, 2.68067772490389322e-03, 1.62824170038242295e-03, -9.51592254519715870e-05, 5.15138902046611451e-05),
};

void OffsetMomentum()
{
    double px = 0, py = 0, pz = 0;
    foreach (var b in bodies)
    {
        px += b.Vx * b.Mass;
        py += b.Vy * b.Mass;
        pz += b.Vz * b.Mass;
    }
    bodies[0].Vx = -px / SolarMass;
    bodies[0].Vy = -py / SolarMass;
    bodies[0].Vz = -pz / SolarMass;
}

void Advance(double dt)
{
    for (int i = 0; i < bodies.Length; i++)
    {
        var a = bodies[i];
        for (int j = i + 1; j < bodies.Length; j++)
        {
            var b = bodies[j];
            double dx = a.X - b.X, dy = a.Y - b.Y, dz = a.Z - b.Z;
            double d2 = dx * dx + dy * dy + dz * dz;
            double mag = dt / (d2 * Math.Sqrt(d2));
            a.Vx -= dx * b.Mass * mag;
            a.Vy -= dy * b.Mass * mag;
            a.Vz -= dz * b.Mass * mag;
            b.Vx += dx * a.Mass * mag;
            b.Vy += dy * a.Mass * mag;
            b.Vz += dz * a.Mass * mag;
        }
    }
    foreach (var b in bodies)
    {
        b.X += dt * b.Vx;
        b.Y += dt * b.Vy;
        b.Z += dt * b.Vz;
    }
}

double Energy()
{
    double e = 0;
    for (int i = 0; i < bodies.Length; i++)
    {
        var a = bodies[i];
        e += 0.5 * a.Mass * (a.Vx * a.Vx + a.Vy * a.Vy + a.Vz * a.Vz);
        for (int j = i + 1; j < bodies.Length; j++)
        {
            var b = bodies[j];
            double dx = a.X - b.X, dy = a.Y - b.Y, dz = a.Z - b.Z;
            e -= a.Mass * b.Mass / Math.Sqrt(dx * dx + dy * dy + dz * dz);
        }
    }
    return e;
}

int n = args.Length > 0 ? int.Parse(args[0]) : 1000;
OffsetMomentum();
Console.WriteLine(Energy().ToString("F9", CultureInfo.InvariantCulture));
for (int i = 0; i < n; i++) Advance(0.01);
Console.WriteLine(Energy().ToString("F9", CultureInfo.InvariantCulture));

class Body
{
    public double X, Y, Z, Vx, Vy, Vz, Mass;
}
