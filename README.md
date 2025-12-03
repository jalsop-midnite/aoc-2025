# AOC 2025

To run a particular day's challenge use `zig build run -- day_x`

e.g.

```sh
> zig build run -- day_1 
Running AOC Day 1
```

## Timing runs

First build in release mode:

`zig build -Doptimize=ReleaseSafe`

then run the binary e.g. for day_2:

`time ./zig-out/bin/aoc_2025 day_2 ./inputs/day_2.txt 2> /dev/null`

