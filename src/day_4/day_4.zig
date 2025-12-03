const std = @import("std");

const aoc_2025 = @import("aoc_2025");

pub fn main(args: *std.process.ArgIterator) !void {
    std.debug.print("Running AOC Day 4\n", .{});

    const file_path = args.next() orelse {
        std.debug.print("Missing file path\n", .{});
        return;
    };

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    _ = reader; // Placeholder to avoid unused variable error

    try aoc_2025.output("{d}\n", .{12345});
}
