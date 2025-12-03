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

        const joltage = getLargestJoltage(joltages);
        total += joltage;
    }

    try aoc_2025.output("{d}\n", .{total});
}

fn parseJoltages(allocator: std.mem.Allocator, line: []const u8) ![]u32 {
    const joltages = try allocator.alloc(u32, line.len);

    for (0..line.len) |i| {
        joltages[i] = try std.fmt.parseInt(u32, line[i .. i + 1], 10);
    }

    return joltages;
}

fn getLargestJoltage(joltages: []const u32) u32 {
    const largest = std.mem.max(u32, joltages);
    const largest_idx = std.mem.indexOfMax(u32, joltages);

    if (largest_idx == joltages.len - 1) {
        const left = std.mem.max(u32, joltages[0 .. joltages.len - 1]);
        const right = largest;

        return 10 * left + right;
    }

    const left = largest;
    const right = std.mem.max(u32, joltages[largest_idx + 1 ..]);

    return 10 * left + right;
}

test "largest possible joltage pair" {
    const allocator = std.testing.allocator;

    const Case = struct {
        line: []const u8,
        expected_joltage: u32,
    };

    const cases: [4]Case = .{
        .{ .line = "987654321111111", .expected_joltage = 98 },
        .{ .line = "811111111111119", .expected_joltage = 89 },
        .{ .line = "234234234234278", .expected_joltage = 78 },
        .{ .line = "818181911112111", .expected_joltage = 92 },
    };

    for (cases) |case| {
        const joltages = try parseJoltages(allocator, case.line);
        defer allocator.free(joltages);

        try std.testing.expectEqual(case.expected_joltage, getLargestJoltage(joltages));
    }
}
