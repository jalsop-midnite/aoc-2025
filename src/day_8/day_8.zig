const std = @import("std");

const aoc_2025 = @import("aoc_2025");

const List = aoc_2025.List;
const Circuit = std.AutoHashMap(Point, void);

const CONNECTIONS: usize = 1000;

pub fn solve(
    allocator: std.mem.Allocator,
    part: aoc_2025.Part,
    input_data: []const u8,
) !u64 {
    return switch (part) {
        .Part1 => try part1(allocator, input_data),
        .Part2 => try part2(allocator, input_data),
    };
}

fn part1(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    const points = try loadPoints(allocator, input_data);
    defer points.deinit();

    var points_to_circuits = std.AutoArrayHashMap(Point, *Circuit).init(allocator);
    defer points_to_circuits.deinit();

    var circuits = try allocator.alloc(Circuit, points.items.len);
    defer {
        for (circuits) |circuit| {
            var c = circuit;
            c.deinit();
        }
        allocator.free(circuits);
    }

    for (points.items, 0..) |point, idx| {
        var circuit = Circuit.init(allocator);
        try circuit.put(point, {});

        circuits[idx] = circuit;
        try points_to_circuits.put(point, &circuits[idx]);
    }

    const num_pairs = (points.items.len * (points.items.len - 1)) / 2;
    const pair_distances = try allocator.alloc(PairDistance, num_pairs);
    defer allocator.free(pair_distances);

    var pairs = iterPairs(points);
    var index: usize = 0;
    while (pairs.next()) |pair| {
        defer index += 1;

        const point_a, const point_b = pair;
        const dist = distanceSquared(point_a, point_b);

        pair_distances[index] = .{
            .point_a = point_a,
            .point_b = point_b,
            .distance = dist,
        };
    }

    // Sort distances
    const sorted_distances = pair_distances[0..index];
    std.sort.heap(
        PairDistance,
        sorted_distances,
        {},
        bySmallestDistance,
    );

    for (sorted_distances[0..CONNECTIONS]) |pair_distance| {
        const point_a = pair_distance.point_a;
        const point_b = pair_distance.point_b;

        std.debug.print("joining points {any} {any}\n", .{ point_a, point_b });

        const circuit_a = points_to_circuits.get(point_a).?;
        const circuit_b = points_to_circuits.get(point_b).?;

        printCircuit(circuit_a.*);
        printCircuit(circuit_b.*);

        if (circuit_a != circuit_b) {
            var b_points = circuit_b.keyIterator();
            while (b_points.next()) |point| {
                try circuit_a.put(point.*, {});
                try points_to_circuits.put(point.*, circuit_a);
            }

            circuit_b.clearAndFree();
        }

        std.debug.print("new circuit", .{});
        printCircuit(circuit_a.*);
    }

    std.sort.heap(Circuit, circuits, {}, circuitSorter);

    var result: u64 = 1;
    const max_circuits = 3;
    for (circuits[0..max_circuits]) |circuit| {
        const size: u64 = @intCast(length(circuit));

        result *= size;
    }

    return result;
}

fn part2(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    std.debug.print("Day 8 Part 2 not implemented\n", .{});
    _ = allocator;
    _ = input_data;
    return error.NotImplemented;
}

const Point = @Vector(3, u32);

const PairDistance = struct {
    point_a: Point,
    point_b: Point,
    distance: f32,
};

fn bySmallestDistance(_: void, a: PairDistance, b: PairDistance) bool {
    return a.distance < b.distance;
}

fn loadPoints(allocator: std.mem.Allocator, input_data: []const u8) !std.array_list.AlignedManaged(Point, null) {
    var list = List(Point).init(allocator);
    errdefer list.deinit();

    var lines_iter = std.mem.splitSequence(u8, input_data, "\n");
    while (lines_iter.next()) |line| {
        const stripped_line = std.mem.trim(u8, line, " \t\r\n");
        if (stripped_line.len == 0) continue;

        // Parse line into point data
        const point = try parsePoint(stripped_line);
        try list.append(point);
    }

    return list;
}

fn parsePoint(line: []const u8) !Point {
    var parts = std.mem.splitSequence(u8, line, ",");
    const x_str = parts.next() orelse return error.InvalidInput;
    const y_str = parts.next() orelse return error.InvalidInput;
    const z_str = parts.next() orelse return error.InvalidInput;

    const x = std.fmt.parseInt(u32, x_str, 10) catch return error.InvalidNumber;
    const y = std.fmt.parseInt(u32, y_str, 10) catch return error.InvalidNumber;
    const z = std.fmt.parseInt(u32, z_str, 10) catch return error.InvalidNumber;

    return Point{ x, y, z };
}

const PairIterator = struct {
    points: []const Point,
    index1: usize,
    index2: usize,

    const Pair = struct {
        Point,
        Point,
    };

    pub fn next(self: *PairIterator) ?Pair {
        if (self.index1 >= self.points.len) {
            return null;
        }

        if (self.index2 >= self.points.len) {
            self.index1 += 1;
            self.index2 = self.index1 + 1;

            if (self.index2 >= self.points.len) {
                return null;
            }
        }

        const p1 = self.points[self.index1];
        const p2 = self.points[self.index2];
        self.index2 += 1;

        return .{ p1, p2 };
    }
};

fn iterPairs(points: std.array_list.AlignedManaged(Point, null)) PairIterator {
    return PairIterator{
        .points = points.items,
        .index1 = 0,
        .index2 = 1,
    };
}

fn closestPair(points: std.array_list.AlignedManaged(Point, null)) @Vector(2, Point) {
    var min_distance: ?f32 = null;
    var min_pair: .{ Point, Point } = undefined;

    std.debug.assert(points.items.len >= 2);

    for (points.items, 0..) |p1, i| {
        for (points.items[i + 1 ..]) |p2| {
            const dist = distanceSquared(p1, p2);
            if (min_distance == null or dist < min_distance.?) {
                min_distance = dist;
                min_pair = .{ p1, p2 };
            }
        }
    }

    std.debug.assert(min_distance != null);

    return min_pair;
}

fn distanceSquared(p1: Point, p2: Point) f32 {
    const dx: f32 = @as(f32, @floatFromInt(p1[0])) - @as(f32, @floatFromInt(p2[0]));
    const dy: f32 = @as(f32, @floatFromInt(p1[1])) - @as(f32, @floatFromInt(p2[1]));
    const dz: f32 = @as(f32, @floatFromInt(p1[2])) - @as(f32, @floatFromInt(p2[2]));

    return dx * dx + dy * dy + dz * dz;
}

fn combineCircuits(
    allocator: std.mem.Allocator,
    circuit_a: Circuit,
    circuit_b: Circuit,
) !Circuit {
    var new_circuit = Circuit.init(allocator);
    errdefer new_circuit.deinit();

    // Add all points from circuit_a
    var it_a = circuit_a.keyIterator();
    while (it_a.next()) |key| {
        try new_circuit.put(key.*, {});
    }

    // Add all points from circuit_b
    var it_b = circuit_b.keyIterator();
    while (it_b.next()) |key| {
        try new_circuit.put(key.*, {});
    }

    return new_circuit;
}

fn circuitSorter(_: void, circuit_a: Circuit, circuit_b: Circuit) bool {
    return length(circuit_a) > length(circuit_b);
}

fn length(circuit: Circuit) usize {
    var size: usize = 0;
    var iter = circuit.keyIterator();
    while (iter.next()) |_| size += 1;

    return size;
}

fn printCircuit(circuit: Circuit) void {
    std.debug.print("Circuit length {d}\n", .{length(circuit)});

    var c_points = circuit.keyIterator();
    while (c_points.next()) |point| {
        std.debug.print("  {any}\n", .{point.*});
    }
}
