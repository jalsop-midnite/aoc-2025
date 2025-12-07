const std = @import("std");

const day_1 = @import("day_1/day_1.zig");
const day_2 = @import("day_2/day_2.zig");
const day_3 = @import("day_3/day_3.zig");
const day_4 = @import("day_4/day_4.zig");
const day_5 = @import("day_5/day_5.zig");
const day_6 = @import("day_6/day_6.zig");
const day_7 = @import("day_7/day_7.zig");

const aoc_2025 = @import("aoc_2025");
const AocDay = aoc_2025.AocDay;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();

    // First arg is the executable path
    const exe_path = args_iter.next() orelse return;
    _ = exe_path; // ignore for now

    const day_arg = args_iter.next() orelse return;
    const day = AocDay.fromString(day_arg) catch |err| {
        std.debug.print("Unknown day: {s}\n", .{day_arg});
        std.debug.print("  Error: {any}\n", .{err});
        return;
    };

    const part_arg = args_iter.next() orelse return;
    const part = aoc_2025.Part.fromString(part_arg) catch |err| {
        std.debug.print("Unknown part: {s}\n", .{part_arg});
        std.debug.print("  Error: {any}\n", .{err});
        return;
    };

    const file_path = args_iter.next() orelse {
        std.debug.print("Missing file path\n", .{});
        return;
    };

    var file_content = std.Io.Writer.Allocating.init(allocator);
    defer file_content.deinit();
    {
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        var buffer: [1024]u8 = undefined;
        var file_reader = file.reader(&buffer);
        const reader = &file_reader.interface;

        _ = try reader.streamRemaining(&file_content.writer);
    }
    const input_data = file_content.written();

    std.debug.print("Data\n{s}\n", .{input_data});

    var maybe_result: ?u64 = null;
    switch (day) {
        AocDay.Day1 => maybe_result = try day_1.main(input_data),
        AocDay.Day2 => maybe_result = try day_2.main(input_data),
        AocDay.Day3 => try day_3.main(&args_iter),
        AocDay.Day4 => try day_4.main(&args_iter),
        AocDay.Day5 => try day_5.main(&args_iter),
        AocDay.Day6 => maybe_result = try day_6.main(allocator, input_data),
        AocDay.Day7 => maybe_result = try day_7.solve(allocator, part, input_data),
    }

    if (maybe_result) |result| {
        try aoc_2025.output("{d}\n", .{result});
    }
}
