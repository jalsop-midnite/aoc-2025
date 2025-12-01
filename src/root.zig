//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const day_1 = @import("day_1/day_1.zig");
pub const day_2 = @import("day_2/day_2.zig");

pub const COMMON_MSG = "This is common code";
