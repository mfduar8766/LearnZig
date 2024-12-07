const std = @import("std");
const Print = std.debug.print;
const expect = std.testing.expect;
const time = std.time;
const os = std.os;
const fs = std.fs;
const eql = std.mem.eql;
const io = std.io;
const assert = std.debug.assert;
const Utils = @import("./utils.zig");
const Types = @import("./types.zig");

pub const Logger = struct {
    time: []const u8 = "",
    level: []const u8 = Types.LogLevels.get(0),
    message: []const u8 = "",
    data: ?[]const u8 = null,
    const Self = @This();

    pub fn new(path: []const u8) !Logger {
        const value = Utils.fileOrDirExists(path);
        if (!value.Ok and value.Err.len > 0) {
            Print("Logger::Logger::new()::dir does not exist. Creating dir:{s}\n", .{path});
            const res = Utils.createDir(path);
            if (res.Err.len > 0) {
                @panic(res.Err);
            } else {
                Print("TIME: {}\n", .{time.timestamp()});
            }
        } else {
            const today = Utils.fromTimestamp(@intCast(time.timestamp()));
            const max_len = 13;
            var buf: [max_len]u8 = undefined;
            const fileName = try std.fmt.bufPrint(&buf, "{}_{}_{}.log", .{ today.year, today.month, today.day });
            Print("FILE_NAME_NO_ERROR_GETTING_FILE: {s}\n", .{fileName});
            try Utils.createFile("Logs", fileName);
        }
        return Logger{};
    }
    pub fn info(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(Types.LogLevels.INFO, message, data);
    }
    pub fn warn(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(Types.LogLevels.WARNING, message, data);
    }
    pub fn err(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(Types.LogLevels.ERROR, message, data);
    }
    pub fn fatal(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(Types.LogLevels.FATAL, message, data);
    }
    fn setValues(self: *Self, level: Types.LogLevels, message: []const u8, data: ?[]const u8) !void {
        switch (level) {
            Types.LogLevels.INFO => self.level = Types.LogLevels.get(0),
            Types.LogLevels.WARNING => self.level = Types.LogLevels.get(1),
            Types.LogLevels.ERROR => self.level = Types.LogLevels.get(2),
            Types.LogLevels.FATAL => self.level = Types.LogLevels.get(3),
        }
        self.message = message;
        if (data) |d| self.data = d;
        const max_len = 20;
        var buf: [max_len]u8 = undefined;
        const timeStamp = try std.fmt.bufPrint(&buf, "{s}", .{Utils.toRFC3339(Utils.fromTimestamp(@intCast(time.timestamp())))});
        self.time = timeStamp;
        try self.createJson();
    }
    fn createJson(self: *Self) !void {
        var buf: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        const alloc = fba.allocator();
        var str = try std.ArrayList(u8).initCapacity(alloc, buf.len);
        defer str.deinit();
        defer fba.reset();
        try std.json.stringify(self.*, .{ .emit_null_optional_fields = false }, str.writer());
        try Utils.writeToFile("2024_12_7.log", str.items);
        Print("{s}\n", .{str.items});
    }
};
