const std = @import("std");
const Logger = @import("./logger.zig").Logger;

pub const App = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;
    allocator: Allocator,
    logger: Logger,

    pub fn init(allocator: Allocator, logger: Logger) Self {
        return Self{
            .allocator = allocator,
            .logger = logger,
        };
    }
    pub fn deInit(self: *Self) !void {
        self.logger.closeDirAndFiles();
    }
};
