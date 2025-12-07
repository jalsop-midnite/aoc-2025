const std = @import("std");

const aoc_2025 = @import("aoc_2025");

const Set = std.AutoHashMap(usize, void);

const SOURCE = 'S';
const SPLITTER = '^';

pub fn solve(
    allocator: std.mem.Allocator,
    part: aoc_2025.Part,
    input_data: []const u8,
) !u64 {
    std.debug.print("Running AOC Day 7: Part {d}\n", .{@intFromEnum(part)});
    return switch (part) {
        .Part1 => try part1(allocator, input_data),
        .Part2 => try part2(allocator, input_data),
    };
}

fn part1(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    std.debug.print("Running AOC Day 7\n", .{});

    var lines_iter = std.mem.splitSequence(u8, input_data, "\n");

    const first_row = lines_iter.next() orelse return error.InvalidInput;
    var beam_positions = try getPositions(allocator, first_row, SOURCE);
    defer beam_positions.deinit();

    var key_iter = beam_positions.keyIterator();
    std.debug.print("Starting beam position {d}\n", .{key_iter.next().?.*});

    var total_splits: u64 = 0;

    while (lines_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");
        if (stripped_line.len == 0) continue;

        var splitters = try getPositions(allocator, line, SPLITTER);
        defer splitters.deinit();

        var split_beams = try intersection(&beam_positions, &splitters);
        defer split_beams.deinit();

        total_splits += @intCast(split_beams.count());

        removeAll(&beam_positions, &split_beams);

        var split_iter = split_beams.keyIterator();
        while (split_iter.next()) |pos| {
            try beam_positions.put(pos.* - 1, {});
            try beam_positions.put(pos.* + 1, {});
        }
    }

    return total_splits;
}

fn part2(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    var lines_iter = std.mem.splitSequence(u8, input_data, "\n");

    const first_row = lines_iter.next() orelse return error.InvalidInput;
    var beam_positions = try getPositions(allocator, first_row, SOURCE);
    defer beam_positions.deinit();

    var timelines = try allocator.alloc(u64, first_row.len);
    defer allocator.free(timelines);

    for (timelines) |*slot| {
        slot.* = 0;
    }

    var key_iter = beam_positions.keyIterator();
    const start_position = key_iter.next().?.*;
    timelines[start_position] = 1;
    std.debug.print("Starting beam position {d}\n", .{start_position});

    while (lines_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");
        if (stripped_line.len == 0) continue;

        var splitters = try getPositions(allocator, line, SPLITTER);
        defer splitters.deinit();

        var split_beams = try intersection(&beam_positions, &splitters);
        defer split_beams.deinit();

        removeAll(&beam_positions, &split_beams);

        var split_iter = split_beams.keyIterator();
        while (split_iter.next()) |pos| {
            try beam_positions.put(pos.* - 1, {});
            try beam_positions.put(pos.* + 1, {});

            const incoming_timelines = timelines[pos.*];
            timelines[pos.* - 1] += incoming_timelines;
            timelines[pos.* + 1] += incoming_timelines;

            timelines[pos.*] = 0;
        }
    }

    var total_timelines: u64 = 0;
    for (timelines) |count| {
        total_timelines += count;
    }
    return total_timelines;
}

fn getPositions(allocator: std.mem.Allocator, line: []const u8, value: u8) !Set {
    var new_positions = Set.init(allocator);
    errdefer new_positions.deinit();

    for (0..line.len) |idx| {
        if (line[idx] == value) {
            _ = try new_positions.put(idx, {});
        }
    }

    return new_positions;
}

fn intersection(set_a: *const Set, set_b: *const Set) !Set {
    var result = Set.init(set_a.allocator);
    errdefer result.deinit();

    var iter = set_a.keyIterator();
    while (iter.next()) |key| {
        if (set_b.get(key.*)) |_| {
            _ = try result.put(key.*, {});
        }
    }

    return result;
}

fn removeAll(set: *Set, to_remove: *const Set) void {
    var iter = to_remove.keyIterator();
    while (iter.next()) |key| {
        _ = set.remove(key.*);
    }
}
