const std = @import("std");

const aoc_2025 = @import("aoc_2025");

const List = aoc_2025.List;

pub fn main(allocator: std.mem.Allocator, input_data: []const u8) !u64 {
    std.debug.print("Running AOC Day 6\n", .{});

    var rows = List([]const u8).init(allocator);
    defer rows.deinit();
    {
        var lines_iter = std.mem.splitSequence(u8, input_data, "\n");
        while (lines_iter.next()) |line| {
            const stripped_line = std.mem.trim(u8, line, " \t\r\n");
            if (stripped_line.len == 0) continue;

            std.debug.print("Read line: {s}\n", .{stripped_line});
            try rows.append(stripped_line);
        }
    }

    const row_width = rows.items[0].len;
    var problems = List(Problem).init(allocator);
    defer {
        for (problems.items) |problem| {
            problem.deinit();
        }
        problems.deinit();
    }

    {
        var current_problem = Problem.init(allocator);

        for (0..row_width) |col_idx| {
            // Parse single column of bytes

            // Grab all number digits
            var digits = List(u8).init(allocator);
            defer digits.deinit();

            for (rows.items[0 .. rows.items.len - 1]) |row| {
                const char = row[col_idx];
                if (char != ' ' and char != '\n') {
                    try digits.append(char);
                }
            }

            if (digits.items.len == 0) {
                // No number in this column, signals end of current problem
                try problems.append(current_problem);
                // Reset
                current_problem = Problem.init(allocator);
                continue;
            } else {
                // Parse number and add to current problem
                const num_str = digits.items;
                const num = try std.fmt.parseInt(u64, num_str, 10);
                try current_problem.numbers.append(num);
            }

            if (current_problem.operator == null) {
                // Try to grab operator
                const last_row = rows.items[rows.items.len - 1];
                const maybe_op = switch (last_row[col_idx]) {
                    '+' => Operator.Add,
                    '*' => Operator.Multiply,
                    else => null,
                };
                if (maybe_op) |op| {
                    current_problem.operator = op;
                }
            }
        }

        // Make sure to add the last problem which doesn't have trailing spaces
        try problems.append(current_problem);
    }

    var total: u64 = 0;
    for (problems.items) |problem| {
        const result = evaluateProblem(problem);
        std.debug.print("  Result: {d}\n", .{result});
        total += result;
    }
    std.debug.print("Total: {d}\n", .{total});

    return total;
}

const Operator = enum(u8) {
    Add = '+',
    Multiply = '*',
};

const Problem = struct {
    numbers: std.array_list.AlignedManaged(u64, null),
    operator: ?Operator = null,

    pub fn init(allocator: std.mem.Allocator) Problem {
        return Problem{
            .numbers = List(u64).init(allocator),
            .operator = null,
        };
    }

    pub fn deinit(self: Problem) void {
        self.numbers.deinit();
    }
};

fn evaluateProblem(problem: Problem) u64 {
    std.debug.assert(problem.operator != null);

    const op = problem.operator.?;
    std.debug.print(
        "Evaluating problem with operator {c} and numbers:\n",
        .{@intFromEnum(op)},
    );
    for (problem.numbers.items) |num| {
        std.debug.print("  {d}\n", .{num});
    }

    var result: u64 = switch (problem.operator.?) {
        Operator.Add => 0,
        Operator.Multiply => 1,
    };

    for (problem.numbers.items) |num| {
        switch (problem.operator.?) {
            Operator.Add => result += num,
            Operator.Multiply => result *= num,
        }
    }

    return result;
}
