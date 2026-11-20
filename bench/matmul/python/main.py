# matmul - naive matrix multiply (i,k,j), Python
import sys

n = int(sys.argv[1]) if len(sys.argv) > 1 else 400
a = [[float((i + j) % 10) for j in range(n)] for i in range(n)]
b = [[float((i * j) % 10) for j in range(n)] for i in range(n)]
c = [[0.0] * n for _ in range(n)]
for i in range(n):
    ci = c[i]
    ai = a[i]
    for k in range(n):
        aik = ai[k]
        bk = b[k]
        for j in range(n):
            ci[j] += aik * bk[j]
print(int(sum(sum(row) for row in c)))
