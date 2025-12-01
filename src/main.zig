const std = @import("std");
const aoc_2025 = @import("aoc_2025");

const AocDay = enum {
    Day1,
    Day2,

    pub fn from_string(s: []const u8) ?AocDay {
        return {
            if (std.mem.eql(u8, s, "day_1")) return AocDay.Day1;
            if (std.mem.eql(u8, s, "day_2")) return AocDay.Day2;

            return null;
        };
    }
};

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
    const day = AocDay.from_string(day_arg) orelse {
        std.debug.print("Unknown day: {s}\n", .{day_arg});
        return;
    };
    switch (day) {
        AocDay.Day1 => try aoc_2025.day_1.main(&args_iter),
        AocDay.Day2 => try aoc_2025.day_2.main(),
    }
}
