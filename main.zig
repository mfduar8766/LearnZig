const std = @import("std");
const Print = std.debug.print;
const expect = std.testing.expect;
const time = std.time;
const os = std.os;
const fs = std.fs;
const eql = std.mem.eql;
const assert = std.debug.assert;
const Utils = @import("./utils.zig");
const Types = @import("./types.zig");
const Logger = @import("./logger.zig").Logger;

// https://stackoverflow.com/questions/72122366/how-to-initialize-variadic-function-arguments-in-zig
// https://www.reddit.com/r/Zig/comments/y5b2xw/anytype_vs_comptime_t/
// https://ziggit.dev/t/format-timestamp-into-iso-8601-strings/3824
// https://www.reddit.com/r/Zig/comments/l0ne7b/is_there_a_way_of_adding_an_optional_fields_in/
// https://ziggit.dev/t/how-to-set-struct-field-with-runtime-values/2758/6
// https://www.aolium.com/karlseguin/cf03dee6-90e1-85ac-8442-cf9e6c11602a

const CHROME_DRIVER_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json";
const SELENIUM_STAND_ALONE_JAR: []const u8 = "https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar";

const Place = struct { lat: f32, long: f32 };

fn createLoggerPayload(useData: bool) type {
    if (useData) {
        return struct {
            time: []const u8 = "",
            level: []const u8 = Types.LogLevels.get(0),
            message: []const u8 = "",
            data: []const u8 = "",
        };
    } else {
        return struct {
            time: []const u8 = "",
            level: []const u8 = Types.LogLevels.get(0),
            message: []const u8 = "",
        };
    }
}

const enable_j: bool = false;

pub fn main() !void {
    const INFO: Types.LogLevels = @enumFromInt(0);
    std.debug.print("ENUMFROMINT: {}\n", .{INFO});
    const name: []const u8 = std.enums.tagName(Types.LogLevels, INFO) orelse "";
    Print("ENUMS: {s}\n", .{name});
    Print("ENUMS2: {s}, @TypeOf({any})\n", .{ Types.LogLevels.get(1), @TypeOf(Types.LogLevels.get(1)) });
    const place: Place = .{ .lat = 22, .long = 44 };
    Print("STRUCT: {any}\n", .{place});
    var logger = try Logger.new("Logs/");
    try logger.info("LOG1", null);
    try logger.warn("LOG2", null);
    try logger.err("LOG3", null);
    try logger.fatal("LOG4", null);

    const A = struct {
        i: i8,
        j: Utils.type_or_void(enable_j, []const u8),
    };
    const a = A{
        .i = 5,
        .j = Utils.value_or_void(enable_j, null),
    };
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const alloc = fba.allocator();
    var str = try std.ArrayList(u8).initCapacity(alloc, buf.len);
    defer str.deinit();
    defer fba.reset();
    try std.json.stringify(a, .{}, str.writer());
    Print("{s}\n", .{str.items});
}
