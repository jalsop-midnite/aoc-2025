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
