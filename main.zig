const std = @import("std");
const Print = std.debug.print;
const Logger = @import("./logger.zig").Logger;
const Utils = @import("./utils.zig");
const Http = @import("./http.zig").Http;

// https://stackoverflow.com/questions/72122366/how-to-initialize-variadic-function-arguments-in-zig
// https://www.reddit.com/r/Zig/comments/y5b2xw/anytype_vs_comptime_t/
// https://ziggit.dev/t/format-timestamp-into-iso-8601-strings/3824
// https://www.reddit.com/r/Zig/comments/l0ne7b/is_there_a_way_of_adding_an_optional_fields_in/
// https://ziggit.dev/t/how-to-set-struct-field-with-runtime-values/2758/6
// https://www.aolium.com/karlseguin/cf03dee6-90e1-85ac-8442-cf9e6c11602a

pub fn main() !void {
    // const CHROME_DRIVER_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json";
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();
    // const serverHeaderBuf: []u8 = try allocator.alloc(u8, 1024 * 8);
    // defer allocator.free(serverHeaderBuf);
    // var req = Utils.Request.init(allocator, .{ .maxReaderSize = 3 * 1024 * 1024 });
    // defer req.deinit();
    // _ = try req.get(CHROME_DRIVER_URL, .{ .server_header_buffer = serverHeaderBuf });

    var logger = try Logger.init("Logs");
    defer {
        logger.closeDirAndFiles();
    }
    try logger.info("LOG1", null);
    try logger.info("LOG2", null);
    try logger.info("LOG3", null);
    try logger.info("LOG4", null);
}
