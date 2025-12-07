const std = @import("std");

const aoc_2025 = @import("aoc_2025");

pub fn solve(
    allocator: std.mem.Allocator,
    part: aoc_2025.Part,
    input_data: []const u8,
) !u64 {
    return switch (part) {
        .Part1 => return error.NotImplemented,
        .Part2 => return part2(allocator, input_data),
    };
}

fn part2(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    var file_iter = std.mem.splitSequence(u8, input_data, "\n");

    var total: u64 = 0;

    while (file_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");

        std.debug.print("Processing line: {s}\n", .{stripped_line});

        const joltages = try parseJoltages(allocator, stripped_line);
        defer allocator.free(joltages);

        const joltage = getLargestJoltage(joltages, 12);
        total += joltage;
    }

    return total;
}

fn parseJoltages(allocator: std.mem.Allocator, line: []const u8) ![]u64 {
    const joltages = try allocator.alloc(u64, line.len);

    for (0..line.len) |i| {
        joltages[i] = try std.fmt.parseInt(u64, line[i .. i + 1], 10);
    }

    return joltages;
}

fn getLargestJoltage(joltages: []const u64, num_digits: u64) u64 {
    var total_joltage: u64 = 0;
    var window_start: u64 = 0;

    if (joltages.len < num_digits) {
        return 0;
    }

    // e.g. 12 digits from a 15 digit line
    // Know first digit must be from the first 4 as othewise there
    // won't be enough space to fill all 12 digits
    // 234234234234278
    // ^^^^
    // First joltage digit is largest in this window which is 4
    // 234234234234278
    // --*                  total_joltage = 4

    // Next window starts after the previous joltage digit which leaves
    // 15 - 3 = 12 digits left to look at
    // Of these 12, we know that the next digit must be in the next
    // 2 as we only need 11 more digits => window_size = 2
    // 234234234234278
    // --*^^
    // Pick the largest in this window, which is 3
    // 234234234234278
    // --*-*                total_joltage = 43

    // Continue this way until the number of possible digits is equal to
    // the number of remaining digits to fill
    // 234234234234278
    // --*-*^
    // 234234234234278
    // --*-**               total_joltage = 434

    // At this points there are only 9 digits on the right and 9 left to fill
    // which would lead to a window size of 0
    // We can now take all remaining digits in order
    // 234234234234278
    // --*-***********      total_joltage = 434234234278

    for (0..num_digits) |i| {
        const remaining = num_digits - i;

        const window_size = joltages.len - window_start - remaining + 1;

        if (window_size > 0) {
            const window = joltages[window_start..][0..window_size];

            const digit = std.mem.max(u64, window);
            const largest_idx = std.mem.indexOfMax(u64, window);
            window_start += largest_idx + 1;

            total_joltage += std.math.pow(u64, 10, remaining - 1) * digit;
        } else {
            const digit = joltages[window_start];
            window_start += 1;

            total_joltage += std.math.pow(u64, 10, remaining - 1) * digit;
        }
    }

    return total_joltage;
}

test "largest possible joltage 2 digits" {
    const allocator = std.testing.allocator;

    const Case = struct {
        line: []const u8,
        expected_joltage: u64,
    };

    const cases: [4]Case = .{
        .{ .line = "811111111111119", .expected_joltage = 89 },
        .{ .line = "987654321111111", .expected_joltage = 98 },
        .{ .line = "234234234234278", .expected_joltage = 78 },
        .{ .line = "818181911112111", .expected_joltage = 92 },
    };

    for (cases) |case| {
        const joltages = try parseJoltages(allocator, case.line);
        defer allocator.free(joltages);

        try std.testing.expectEqual(case.expected_joltage, getLargestJoltage(joltages, 2));
    }
}

test "largest possible joltage 12 digits" {
    const allocator = std.testing.allocator;

    const Case = struct {
        line: []const u8,
        expected_joltage: u64,
    };

    const cases: [4]Case = .{
        .{ .line = "987654321111111", .expected_joltage = 987654321111 },
        .{ .line = "811111111111119", .expected_joltage = 811111111119 },
        .{ .line = "234234234234278", .expected_joltage = 434234234278 },
        .{ .line = "818181911112111", .expected_joltage = 888911112111 },
    };

    for (cases) |case| {
        const joltages = try parseJoltages(allocator, case.line);
        defer allocator.free(joltages);

        try std.testing.expectEqual(case.expected_joltage, getLargestJoltage(joltages, 12));
    }
}
