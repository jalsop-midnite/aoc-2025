const std = @import("std");

pub const AocDay = enum(u8) {
    Day1 = 1,
    Day2 = 2,
    Day3 = 3,
    Day4 = 4,
    Day5 = 5,
    Day6 = 6,

    pub fn fromString(s: []const u8) !AocDay {
        const prefix = "day_";
        if (s.len < prefix.len) return error.InvalidPrefix;
        if (!std.mem.eql(u8, s[0..prefix.len], prefix)) return error.InvalidPrefix;

        const int = std.fmt.parseInt(u8, s[prefix.len..], 10) catch return error.InvalidNumber;

        if (int == 0 or int > AocDay.maxDay()) return error.DayOutOfRange;

        return @enumFromInt(int);
    }

    inline fn maxDay() u8 {
        var _max: u8 = 0;
        inline for (std.meta.fields(@This())) |day| {
            const value = day.value;
            if (_max < value) {
                _max = value;
            }
        }
        return _max;
    }
};

pub const LinesIterator = struct {
    delimiter: u8 = '\n',
    reader: *std.io.Reader,

    pub fn next(self: *LinesIterator) !?[]const u8 {
        const line = self.reader.takeDelimiterExclusive(self.delimiter) catch |err| {
            switch (err) {
                error.EndOfStream => return null,
                else => return err,
            }
        };

        // Skip the delimiter char
        _ = self.reader.take(1) catch |err| {
            if (err != error.EndOfStream) {
                return err;
            }
        };

        return line;
    }
};

pub fn output(comptime fmt: []const u8, args: anytype) !void {
    var buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&buf);
    const writer = &stdout_writer.interface;
    try writer.print(fmt, args);
    try writer.flush();
}

pub fn Solution() type {
    return struct {
        pub fn part1() !u64 {
            std.debug.print("Part 1 not implemented\n", .{});
            return error.NotImplemented;
        }

        pub fn part2() !u64 {
            std.debug.print("Part 2 not implemented\n", .{});
            return error.NotImplemented;
        }
    };
}
