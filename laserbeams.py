from time import time

def gcd(x, y):
    if y == 0:
        return x
    return gcd(y, x % y)


def laserbeam(n):
    if n % 2 == 0:
        return 0
    if n == 1:
        return 1
    r = (n + 3) // 2  # number of rows
    x0 = (-r) % 3
    cnt = 0
    for x in range(x0, r // 2, 3):
        y = r - x
        if gcd(x, y) == 1:
            cnt += 1
    return 2 * cnt

def timereps(reps, func):
    start = time()
    for i in range(0, reps):
        func()
    end = time()
    return (end - start) / reps

if __name__ == "__main__":
    with open("input.txt") as f:
        times = []
        for n in f.readlines():
            n = int(n)
            times.append(timereps(3, lambda: laserbeam(n)))
            print(laserbeam(n))
        print(times)
    
    # 2
    # 80840