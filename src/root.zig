const std = @import("std");

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
