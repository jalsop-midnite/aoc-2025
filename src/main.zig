const std = @import("std");

const day_1 = @import("day_1/day_1.zig");
const day_2 = @import("day_2/day_2.zig");
const day_3 = @import("day_3/day_3.zig");
const day_4 = @import("day_4/day_4.zig");
const day_5 = @import("day_5/day_5.zig");
const day_6 = @import("day_6/day_6.zig");

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
    switch (day) {
        AocDay.Day1 => try day_1.main(&args_iter),
        AocDay.Day2 => try day_2.main(&args_iter),
        AocDay.Day3 => try day_3.main(&args_iter),
        AocDay.Day4 => try day_4.main(&args_iter),
        AocDay.Day5 => try day_5.main(&args_iter),
        AocDay.Day6 => try day_6.main(&args_iter),
    }
}
