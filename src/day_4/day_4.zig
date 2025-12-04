const std = @import("std");

const aoc_2025 = @import("aoc_2025");

const ROLLS_TO_BE_SURROUNDED: usize = 4;

pub fn main(args: *std.process.ArgIterator) !void {
    std.debug.print("Running AOC Day 4\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file_path = args.next() orelse {
        std.debug.print("Missing file path\n", .{});
        return;
    };

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;
    var file_iter = aoc_2025.LinesIterator{
        .delimiter = '\n',
        .reader = reader,
    };

    var data = std.ArrayList(bool).empty;
    defer data.deinit(allocator);

    var width: usize = 0;
    var height: usize = 0;

    while (try file_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");
        if (width == 0) {
            width = stripped_line.len;
        } else if (stripped_line.len != width) {
            // All lines must be the same width
            return error.InvalidInput;
        }

        std.debug.print("Read line: {s}\n", .{stripped_line});

        try data.appendNTimes(allocator, false, width);
        const data_buf = data.items[data.items.len - width ..];

        _ = try parseRow(data_buf, stripped_line);

        height += 1;
    }

    const grid = Grid{
        .data = data,
        .width = width,
        .height = height,
    };

    std.debug.print("Grid size: {d} x {d}\n", .{ grid.width, grid.height });
    std.debug.print("Total points: {d}\n", .{grid.data.items.len});

    var total_accessible: usize = 0;
    for (0..grid.data.items.len) |idx| {
        const point = grid.indexToPoint(idx);

        // We only care about paper that may be surround so skip non-paper
        if (!grid.at(point.x, point.y)) continue;

        if (!isSurrounded(&grid, point)) {
            total_accessible += 1;
        }
    }

    try aoc_2025.output("{d}\n", .{total_accessible});
}

fn parseRow(buffer: []bool, line: []const u8) ![]bool {
    for (0..line.len) |i| {
        switch (line[i]) {
            '.' => buffer[i] = false,
            '@' => buffer[i] = true,
            else => return error.InvalidInput,
        }
    }

    return buffer[0..line.len];
}

const Grid = struct {
    data: std.ArrayList(bool),
    width: usize,
    height: usize,

    pub fn at(self: *const Grid, x: usize, y: usize) bool {
        if (0 > x or x >= self.width or 0 > y or y >= self.height) {
            return false;
        }
        return self.data.items[y * self.width + x];
    }

    pub fn indexToPoint(self: *const Grid, index: usize) Point {
        const x = index % self.width;
        const y = index / self.width;
        return .{ .x = x, .y = y };
    }
};

const Point = struct {
    x: usize,
    y: usize,
};

fn isSurrounded(grid: *const Grid, point: Point) bool {
    const Direction = struct { i32, i32 };

    const directions: [8]Direction = .{
        .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 }, // above the point
        .{ -1, 0 }, .{ 1, 0 }, // intentionally skip 0,0 so we don't look at the point itself
        .{ -1, 1 }, .{ 0, 1 }, .{ 1, 1 }, // below the point
    };

    var surrounded_by: usize = 0;
    for (directions) |direction| {
        const dir_x = direction.@"0";
        const dir_y = direction.@"1";

        const check_x: i32 = @as(i32, @intCast(point.x)) + dir_x;
        const check_y: i32 = @as(i32, @intCast(point.y)) + dir_y;

        if (check_x < 0 or check_y < 0) continue;

        if (grid.at(@intCast(check_x), @intCast(check_y))) surrounded_by += 1;

        if (surrounded_by >= ROLLS_TO_BE_SURROUNDED) {
            return true;
        }
    }

    return false;
}
