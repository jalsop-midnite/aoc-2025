const std = @import("std");

const aoc_2025 = @import("aoc_2025");

pub fn main(args: *std.process.ArgIterator) !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Running AOC Day 2\n", .{});

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
        .delimiter = ',',
        .reader = reader,
    };

    var total: u64 = 0;

    while (try file_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");

        std.debug.print("Read line: {s}\n", .{stripped_line});

        const id_range = try parseIdRange(stripped_line);
        std.debug.print("Parsed ID Range. Start = {d}, End = {d}\n", .{ id_range.start, id_range.end });

        for (id_range.start..id_range.end) |id| {
            if (try isInvalidId(id)) {
                std.debug.print("Invalid ID found: {d}\n", .{id});
                total += id;
            }
        }
    }

    std.debug.print("Total of invalid IDs: {d}\n", .{total});
}

const IdRange = struct {
    start: u64,
    end: u64,
};

fn parseIdRange(line: []const u8) !IdRange {
    var parts_iter = std.mem.splitScalar(u8, line, '-');
    const start_str = parts_iter.next() orelse return error.InvalidFormat;
    const end_str = parts_iter.next() orelse return error.InvalidFormat;

    return IdRange{
        .start = std.fmt.parseInt(u64, start_str, 10) catch return error.InvalidFormat,
        .end = std.fmt.parseInt(u64, end_str, 10) catch return error.InvalidFormat,
    };
}

fn isInvalidId(id: u64) !bool {
    var buf: [100]u8 = undefined;

    const id_str = try std.fmt.bufPrint(&buf, "{d}", .{id});

    if (id_str.len % 2 != 0) {
        return false;
    }

    const first_half = id_str[0..(id_str.len / 2)];
    const second_half = id_str[(id_str.len / 2)..];

    return std.mem.eql(u8, first_half, second_half);
}
