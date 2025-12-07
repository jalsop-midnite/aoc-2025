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
    var parts = std.mem.splitSequence(u8, input_data, "\n\n");

    const range_data = parts.next() orelse {
        std.debug.print("Missing ranges part\n", .{});
        return error.MissingRanges;
    };

    std.debug.print("Range data\n{s}\n", .{range_data});
    const ids_data = parts.next() orelse {
        std.debug.print("Missing ids part\n", .{});
        return error.MissingIds;
    };
    std.debug.print("Id data\n{s}\n", .{ids_data});

    var ranges = AggregatedRanges{};
    defer ranges.deinit(allocator);

    var range_data_iter = std.mem.splitSequence(u8, range_data, "\n");
    while (range_data_iter.next()) |lower_upper| {
        var bounds = std.mem.splitSequence(u8, lower_upper, "-");

        const lower = try std.fmt.parseInt(u64, bounds.next().?, 10);
        const upper = try std.fmt.parseInt(u64, bounds.next().?, 10);

        std.debug.print("Add range {d} - {d}\n", .{ lower, upper });
        const range = Range{
            .start = lower,
            .end = upper,
        };

        try ranges.addRange(allocator, range);
    }

    var fresh_ids: u64 = 0;
    var end: u64 = 0;

    std.debug.print("Counting fresh ids:\n", .{});
    var range_iter = ranges.iter();
    while (range_iter.next()) |range_node| {
        const range = &range_node.range;

        std.debug.assert(end < range.start - 1);

        end = range.end;

        std.debug.print("Aggregated range {d} - {d}\n", .{ range.start, range.end });
        std.debug.print("  Count: {d}\n", .{range.end - range.start + 1});

        fresh_ids += range.end - range.start + 1;
    }

    return fresh_ids;
}

const Range = struct {
    start: u64,
    end: u64,
};

const AggregatedRanges = struct {
    nodes: std.DoublyLinkedList = .{},

    const RangeNode = struct {
        range: Range,
        node: std.DoublyLinkedList.Node,
    };

    const Iter = struct {
        current_node: ?*std.DoublyLinkedList.Node,

        pub fn next(self: *Iter) ?*RangeNode {
            if (self.current_node) |current_node| {
                // Intrusive data structure magic which is now built-in
                const range_node = @as(*RangeNode, @fieldParentPtr("node", current_node));
                self.current_node = current_node.next;
                return range_node;
            } else {
                return null;
            }
        }
    };

    pub fn deinit(self: *AggregatedRanges, allocator: std.mem.Allocator) void {
        while (self.nodes.first) |node| {
            self.remove(
                allocator,
                @fieldParentPtr("node", node),
            );
        }
    }

    pub fn iter(self: *const AggregatedRanges) Iter {
        return .{
            .current_node = self.nodes.first,
        };
    }

    pub fn addRange(self: *AggregatedRanges, allocator: std.mem.Allocator, range: Range) !void {
        const new_range = try allocator.create(RangeNode);
        new_range.range = range;
        new_range.node = .{};

        if (self.nodes.first == null) {
            // First range being added
            self.nodes.append(&new_range.node);
            return;
        }

        var iterator = self.iter();
        var inserted = false;
        while (iterator.next()) |range_node| {
            const existing_range = &range_node.range;

            // Maintain order of ranges using start value when adding new range
            if (range.start > existing_range.start) {
                continue;
            }

            self.nodes.insertBefore(&range_node.node, &new_range.node);
            inserted = true;
            break;
        }

        // Handle the case where the new range is the largest and goes at the end
        if (!inserted) {
            self.nodes.append(&new_range.node);
        }

        self.aggregate(allocator);
    }

    fn aggregate(self: *AggregatedRanges, allocator: std.mem.Allocator) void {
        // Make sure adjacent ranges are merged after adding a new range

        var left = self.nodes.first;
        while (left) |left_node| {
            const left_range: *RangeNode = @fieldParentPtr("node", left_node);

            if (left_node.next) |right_node| {
                const right_range: *RangeNode = @fieldParentPtr("node", right_node);

                if (left_range.range.end + 1 >= right_range.range.start) {
                    // Merge together by extending left range and removing right range
                    left_range.range.end = @max(left_range.range.end, right_range.range.end);
                    self.remove(allocator, right_range);
                    // Stay on the same left node to check for further merges
                    continue;
                }

                left = right_node;
            } else {
                break;
            }
        }
    }

    fn remove(self: *AggregatedRanges, allocator: std.mem.Allocator, range_node: *RangeNode) void {
        self.nodes.remove(&range_node.node);
        allocator.destroy(range_node);
    }
};

test "memory cleanup" {
    const allocator = std.testing.allocator;
    var ranges = AggregatedRanges{};

    try ranges.addRange(allocator, .{ .start = 1, .end = 5 });

    ranges.deinit(allocator);
}

test "add ranges maintains order" {
    const allocator = std.testing.allocator;
    var ranges = AggregatedRanges{};
    defer ranges.deinit(allocator);

    try ranges.addRange(allocator, .{ .start = 5, .end = 10 });
    try ranges.addRange(allocator, .{ .start = 18, .end = 20 });
    try ranges.addRange(allocator, .{ .start = 12, .end = 15 });

    var iter = ranges.iter();

    const range1 = iter.next().?;
    try std.testing.expectEqual(5, range1.range.start);
    try std.testing.expectEqual(10, range1.range.end);

    const range2 = iter.next().?;
    try std.testing.expect(range2.range.start == 12);
    try std.testing.expect(range2.range.end == 15);

    const range3 = iter.next().?;
    try std.testing.expect(range3.range.start == 18);
    try std.testing.expect(range3.range.end == 20);
}

test "aggregation" {
    const allocator = std.testing.allocator;
    var ranges = AggregatedRanges{};
    defer ranges.deinit(allocator);

    // should merge to 1-7
    try ranges.addRange(allocator, .{ .start = 1, .end = 5 });
    try ranges.addRange(allocator, .{ .start = 4, .end = 7 });

    // should merge to 9-14
    try ranges.addRange(allocator, .{ .start = 9, .end = 11 });
    try ranges.addRange(allocator, .{ .start = 12, .end = 14 });

    // should merge to 20-35
    try ranges.addRange(allocator, .{ .start = 20, .end = 24 });
    try ranges.addRange(allocator, .{ .start = 30, .end = 35 });
    try ranges.addRange(allocator, .{ .start = 23, .end = 31 });

    {
        var iter = ranges.iter();

        const range1 = iter.next().?;
        try std.testing.expectEqual(1, range1.range.start);
        try std.testing.expectEqual(7, range1.range.end);

        const range2 = iter.next().?;
        try std.testing.expectEqual(9, range2.range.start);
        try std.testing.expectEqual(14, range2.range.end);

        const range3 = iter.next().?;
        try std.testing.expectEqual(20, range3.range.start);
        try std.testing.expectEqual(35, range3.range.end);
    }

    {
        try ranges.addRange(allocator, .{ .start = 7, .end = 21 });
        var iter = ranges.iter();

        const full_range = iter.next().?;
        try std.testing.expectEqual(1, full_range.range.start);
        try std.testing.expectEqual(35, full_range.range.end);
    }
}
