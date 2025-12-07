# AOC 2025

To run a particular day's challenge use `zig build run -- day_x part_y`

e.g.

```sh
> zig build run -- day_7 part_1 
Running AOC Day 7
...
```

## Timing runs

First build in release mode:

`zig build -Doptimize=ReleaseSafe`

then run the binary e.g. for day_2:

`/usr/bin/time -l -h -p ./zig-out/bin/aoc_2025 day_2 part_2 ./inputs/day_2.txt`

