const std = @import("std");

const day_1 = @import("day_1/day_1.zig");
const day_2 = @import("day_2/day_2.zig");
const day_3 = @import("day_3/day_3.zig");
const day_4 = @import("day_4/day_4.zig");
const day_5 = @import("day_5/day_5.zig");

const AocDay = enum {
    Day1,
    Day2,
    Day3,
    Day4,
    Day5,

    pub fn from_string(s: []const u8) ?AocDay {
        return {
            if (std.mem.eql(u8, s, "day_1")) return AocDay.Day1;
            if (std.mem.eql(u8, s, "day_2")) return AocDay.Day2;
            if (std.mem.eql(u8, s, "day_3")) return AocDay.Day3;
            if (std.mem.eql(u8, s, "day_4")) return AocDay.Day4;
            if (std.mem.eql(u8, s, "day_5")) return AocDay.Day5;

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
        AocDay.Day1 => try day_1.main(&args_iter),
        AocDay.Day2 => try day_2.main(&args_iter),
        AocDay.Day3 => try day_3.main(&args_iter),
        AocDay.Day4 => try day_4.main(&args_iter),
        AocDay.Day5 => try day_5.main(&args_iter),
    }
}
