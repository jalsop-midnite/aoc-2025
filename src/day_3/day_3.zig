const std = @import("std");

const aoc_2025 = @import("aoc_2025");

pub fn main(args: *std.process.ArgIterator) !void {
    std.debug.print("Running AOC Day 3\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file_path = args.next() orelse {
        std.debug.print("Missing file path\n", .{});
        return;
    };

    std.debug.print("Got file path {s}\n", .{file_path});

    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
        return err;
    };
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    var file_iter = aoc_2025.LinesIterator{
        .delimiter = '\n',
        .reader = reader,
    };

    var total: u64 = 0;

    while (try file_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");

        std.debug.print("Read line: {s}\n", .{stripped_line});

        const joltages = try parseJoltages(allocator, stripped_line);
        defer allocator.free(joltages);

        const joltage = getLargestJoltage(joltages, 12);
        total += joltage;
    }

    try aoc_2025.output("{d}\n", .{total});
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

    for (0..num_digits) |i| {
        const remaining = num_digits - i;

        const window_size = joltages.len - window_start - remaining + 1;

        if (window_size > 0) {
            const window = joltages[window_start..][0..window_size];

            const largest = std.mem.max(u64, window);
            const largest_idx = std.mem.indexOfMax(u64, window);

            total_joltage += std.math.pow(u64, 10, remaining - 1) * largest;
            window_start += largest_idx + 1;
        } else {
            const digit = joltages[window_start];
            total_joltage += std.math.pow(u64, 10, remaining - 1) * digit;
            window_start += 1;
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
