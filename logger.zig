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
    logDir: fs.Dir = undefined,
    logDirPath: []const u8 = "Logs",
    logData: LoggerData = undefined,
    logFile: fs.File = undefined,
    filename: []const u8 = "",
    const Self = @This();

    pub fn init(dir: []const u8) !Logger {
        var logger = Logger{};
        if (dir.len > 0) logger.logDirPath = dir;
        const value = Utils.fileOrDirExists(dir);
        if (!value.Ok and value.Err.len > 0) {
            Print("Logger::init()::dir does not exist. Creating dir:{s}\n", .{dir});
            const res = Utils.createDir(dir);
            if (res.Err.len > 0) {
                @panic(res.Err);
            } else {
                Print("Logger::init()::dir:{s} created\n", .{dir});
                try logger.createLogFile(dir);
            }
        } else {
            try logger.createLogFile(dir);
        }
        logger.logData = LoggerData.init();
        logger.logDir = try Utils.openDir(dir);
        logger.logFile = try logger.logDir.openFile("2024_12_7.log", fs.File.OpenFlags{ .mode = fs.File.OpenMode.read_write });
        return logger;
    }
    pub fn info(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.logData.info(self.logFile, message, data);
    }
    pub fn warn(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.logData.warn(self.logFile, Types.LogLevels.WARNING, message, data);
    }
    pub fn err(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.logData.err(self.logFile, Types.LogLevels.ERROR, message, data);
    }
    pub fn fatal(self: *Self, message: []const u8, data: ?[]const u8) !void {
        try self.logData.fatal(self.logFile, Types.LogLevels.FATAL, message, data);
    }
    pub fn closeDirAndFiles(self: *Self) void {
        self.logDir.close();
        self.logFile.close();
    }
    fn createLogFile(self: *Self, dir: []const u8) !void {
        const today = Utils.fromTimestamp(@intCast(time.timestamp()));
        const max_len = 13;
        var buf: [max_len]u8 = undefined;
        const fileName = try std.fmt.bufPrint(&buf, "{}_{}_{}.log", .{ today.year, today.month, today.day });
        try Utils.createFile(dir, fileName);
        self.filename = fileName;
    }
};

const LoggerData = struct {
    time: []const u8 = "",
    level: []const u8 = Types.LogLevels.get(0),
    message: []const u8 = "",
    data: ?[]const u8 = null,
    const Self = @This();

    pub fn init() LoggerData {
        return LoggerData{};
    }
    pub fn info(self: *Self, file: fs.File, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(file, Types.LogLevels.INFO, message, data);
    }
    pub fn warn(self: *Self, file: fs.File, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(file, Types.LogLevels.WARNING, message, data);
    }
    pub fn err(self: *Self, file: fs.File, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(file, Types.LogLevels.ERROR, message, data);
    }
    pub fn fatal(self: *Self, file: fs.File, message: []const u8, data: ?[]const u8) !void {
        try self.setValues(file, Types.LogLevels.FATAL, message, data);
    }
    fn setValues(self: *Self, file: fs.File, level: Types.LogLevels, message: []const u8, data: ?[]const u8) !void {
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
        try self.createJson(file);
    }
    fn createJson(self: *Self, file: fs.File) !void {
        var buf: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        var string = try std.ArrayList(u8).initCapacity(fba.allocator(), buf.len);
        try std.json.stringify(self.*, .{ .emit_null_optional_fields = false }, string.writer());
        try writeToFile(file, string.items);
    }
    fn writeToFile(file: fs.File, bytes: []const u8) !void {
        var bufWriter = io.bufferedWriter(file.writer());
        const writer = bufWriter.writer();
        _ = try writer.print("{s}\n", .{bytes});
        try bufWriter.flush();
        Print("{s}\n", .{bytes});
    }
};
