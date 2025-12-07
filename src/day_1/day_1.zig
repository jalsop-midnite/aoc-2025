const std = @import("std");
const aoc_2025 = @import("aoc_2025");

const DIAL_SIZE = 100;

pub fn solve(part: aoc_2025.Part, input_data: []const u8) !u64 {
    return switch (part) {
        .Part1 => return error.NotImplemented,
        .Part2 => return part2(input_data),
    };
}

fn part2(input_data: []const u8) !u64 {
    var zeroes: i64 = 0;
    var current_rotation: i64 = 50;

    var lines_iter = std.mem.splitSequence(u8, input_data, "\n");
    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;

        std.debug.print("Current Position: {d}, Rotation: {s}\n", .{ current_rotation, line });

        const rotation = try getValueFromLine(line);
        const extra_zeroes = countZeroes(current_rotation, rotation);

        if (extra_zeroes != 0) {
            zeroes += extra_zeroes;
            std.debug.print("Hit zero {d} times! Total so far: {d}\n", .{ extra_zeroes, zeroes });
        }

        current_rotation = applyRotation(current_rotation, rotation);
    }

    std.debug.print("Total zeroes hit: {d}\n", .{zeroes});
    return @intCast(zeroes);
}

fn getValueFromLine(line: []const u8) !i64 {
    const sign: i64 = if (line[0] == 'L')
        -1
    else
        1;

    const value = try std.fmt.parseInt(i64, line[1..], 10);

    return sign * value;
}

fn applyRotation(current: i64, rotation: i64) i64 {
    return @mod((current + rotation), DIAL_SIZE);
}

fn countZeroes(current: i64, rotation: i64) i64 {
    const final_pos = current + rotation;
    const signed_zeroes = @divFloor(final_pos, DIAL_SIZE);

    // current = 10, rotation = 95
    // -> final_pos = 105
    // -> signed_zeroes = 105 // 100 = 1

    if (rotation > 0) {
        return signed_zeroes;
    }

    // Change co-ords so that the rotation is positive
    return countZeroes(@mod(DIAL_SIZE - current, DIAL_SIZE), -rotation);
}

test "countZeroes positive rotations" {
    try std.testing.expectEqual(1, countZeroes(50, 60));
    try std.testing.expectEqual(1, countZeroes(90, 10));
    try std.testing.expectEqual(0, countZeroes(40, 20));
    try std.testing.expectEqual(10, countZeroes(50, 1000));

    try std.testing.expectEqual(1, countZeroes(0, 100));
    try std.testing.expectEqual(0, countZeroes(0, 50));
}

test "countZeroes negative rotations" {
    try std.testing.expectEqual(0, countZeroes(90, -5));

    try std.testing.expectEqual(1, countZeroes(10, -20));
    try std.testing.expectEqual(1, countZeroes(10, -10));
    try std.testing.expectEqual(2, countZeroes(10, -110));
    try std.testing.expectEqual(10, countZeroes(50, -1000));

    try std.testing.expectEqual(1, countZeroes(0, -100));
    try std.testing.expectEqual(0, countZeroes(0, -50));
}
