const std = @import("std");

const aoc_2025 = @import("aoc_2025");

pub fn main(args: *std.process.ArgIterator) !void {
    std.debug.print("Running AOC Day 5\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file_path = args.next() orelse {
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
    std.debug.print("Data\n{s}\n", .{file_content.written()});

    var parts = std.mem.splitSequence(u8, file_content.written(), "\n\n");

    const range_data = parts.next() orelse {
        std.debug.print("Missing ranges part\n", .{});
        return;
    };

    std.debug.print("Range data\n{s}\n", .{range_data});
    const ids_data = parts.next() orelse {
        std.debug.print("Missing ids part\n", .{});
        return;
    };
    std.debug.print("Id data\n{s}\n", .{ids_data});

    var ranges = std.ArrayList(Range).empty;
    defer ranges.deinit(allocator);

    var range_iter = std.mem.splitSequence(u8, range_data, "\n");
    while (range_iter.next()) |lower_upper| {
        var bounds = std.mem.splitSequence(u8, lower_upper, "-");
        const lower = std.fmt.parseInt(u64, bounds.next().?, 10) catch |err| {
            std.debug.print("Invalid lower bound: {s}\n", .{lower_upper});
            return err;
        };
        const upper = try std.fmt.parseInt(u64, bounds.next().?, 10);

        std.debug.print("Add range {d} - {d}\n", .{ lower, upper });
        try ranges.append(
            allocator,
            Range{
                .start = lower,
                .end = upper,
            },
        );
    }

    var fresh_ids: usize = 0;
    var id_iter = std.mem.splitSequence(u8, ids_data, "\n");
    while (id_iter.next()) |id_string| {
        if (id_string.len == 0) continue;

        std.debug.print("Check id: {s}\n", .{id_string});
        const id = try std.fmt.parseInt(u64, id_string, 10);

        var is_fresh = false;
        for (ranges.items) |range| {
            if (range.start <= id and id <= range.end) {
                is_fresh = true;
                break;
            }
        }

        if (is_fresh) {
            fresh_ids += 1;
        }
    }

    try aoc_2025.output("{d}\n", .{fresh_ids});
}

const Range = struct {
    start: u64,
    end: u64,
};
