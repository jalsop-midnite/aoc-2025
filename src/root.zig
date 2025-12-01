const std = @import("std");

pub const LinesIterator = struct {
    reader: *std.io.Reader,

    pub fn next(self: *LinesIterator) !?[]const u8 {
        const line = self.reader.takeDelimiterExclusive('\n') catch |err| {
            switch (err) {
                error.EndOfStream => return null,
                else => return err,
            }
        };

        // Skip the newline
        _ = self.reader.toss(1);

        return line;
    }
};
