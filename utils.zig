const std = @import("std");
const fs = std.fs;
const os = std.os;
// const FileError = std.meta.Tuple(&.{(fs.SelfExePathError || fs.OpenSelfExeError || fs.GetAppDataDirError)});
const io = std.io;

pub const DateTime = struct {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8,
};

pub fn fromTimestamp(ts: u64) DateTime {
    const SECONDS_PER_DAY = 86400;
    const DAYS_PER_YEAR = 365;
    const DAYS_IN_4YEARS = 1461;
    const DAYS_IN_100YEARS = 36524;
    const DAYS_IN_400YEARS = 146097;
    const DAYS_BEFORE_EPOCH = 719468;

    const seconds_since_midnight: u64 = @rem(ts, SECONDS_PER_DAY);
    var day_n: u64 = DAYS_BEFORE_EPOCH + ts / SECONDS_PER_DAY;
    var temp: u64 = 0;

    temp = 4 * (day_n + DAYS_IN_100YEARS + 1) / DAYS_IN_400YEARS - 1;
    var year: u16 = @intCast(100 * temp);
    day_n -= DAYS_IN_100YEARS * temp + temp / 4;

    temp = 4 * (day_n + DAYS_PER_YEAR + 1) / DAYS_IN_4YEARS - 1;
    year += @intCast(temp);
    day_n -= DAYS_PER_YEAR * temp + temp / 4;

    var month: u8 = @intCast((5 * day_n + 2) / 153);
    const day: u8 = @intCast(day_n - (@as(u64, @intCast(month)) * 153 + 2) / 5 + 1);

    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }

    return DateTime{ .year = year, .month = month, .day = day, .hour = @intCast(seconds_since_midnight / 3600), .minute = @intCast(seconds_since_midnight % 3600 / 60), .second = @intCast(seconds_since_midnight % 60) };
}

pub fn toRFC3339(dt: DateTime) [20]u8 {
    var buf: [20]u8 = undefined;
    _ = std.fmt.formatIntBuf(buf[0..4], dt.year, 10, .lower, .{ .width = 4, .fill = '0' });
    buf[4] = '-';
    paddingTwoDigits(buf[5..7], dt.month);
    buf[7] = '-';
    paddingTwoDigits(buf[8..10], dt.day);
    buf[10] = 'T';

    paddingTwoDigits(buf[11..13], dt.hour);
    buf[13] = ':';
    paddingTwoDigits(buf[14..16], dt.minute);
    buf[16] = ':';
    paddingTwoDigits(buf[17..19], dt.second);
    buf[19] = 'Z';

    return buf;
}

fn paddingTwoDigits(buf: *[2]u8, value: u8) void {
    switch (value) {
        0 => buf.* = "00".*,
        1 => buf.* = "01".*,
        2 => buf.* = "02".*,
        3 => buf.* = "03".*,
        4 => buf.* = "04".*,
        5 => buf.* = "05".*,
        6 => buf.* = "06".*,
        7 => buf.* = "07".*,
        8 => buf.* = "08".*,
        9 => buf.* = "09".*,
        // todo: optionally can do all the way to 59 if you want
        else => _ = std.fmt.formatIntBuf(buf, value, 10, .lower, .{}),
    }
}

const ErrorsEnum = enum(u2) {
    FILE_ERROR = 0,
    pub fn getError(key: u2, err: anyerror) anyerror {
        const errorName: [:0]const u8 = @errorName(err);
        const fromInt: ErrorsEnum = @enumFromInt(key);
        std.debug.print("ERR-NAME: {s}\n", .{errorName});
        std.debug.print("FROM-INT: {any}\n", .{fromInt});
        const name: []const u8 = std.enums.tagName(ErrorsEnum, fromInt) orelse "";
        std.debug.print("NAME: {s}\n", .{name});

        const ErrorSet = error{
            FileNotOpen,
        };
        std.debug.print("GFFG: {any}, @typeOf({})\n", .{ ErrorSet.FileNotOpen, @TypeOf(ErrorSet) });

        return ErrorSet.FileNotOpen;
    }
};

pub const Result = struct {
    Ok: bool = false,
    Err: [:0]const u8 = "",
};

pub fn type_or_void(comptime c: bool, comptime t: type) type {
    if (c) {
        return t;
    } else {
        return void;
    }
}

pub fn value_or_void(comptime c: bool, v: anytype) type_or_void(c, @TypeOf(v)) {
    if (c) {
        return v;
    } else {
        return {};
    }
}

pub fn getCWD() fs.Dir {
    return fs.cwd();
}

pub fn fileOrDirExists(path: []const u8) Result {
    const stat = getCWD().statFile(path) catch |err| {
        std.debug.print("Utils::FileOrDirExists()::error: {}\n", .{err});
        return createErrorStruct(false, err);
    };
    return switch (stat.kind) {
        .directory => createErrorStruct(true, null),
        .file => createErrorStruct(true, null),
        else => {
            std.debug.print("{s}\n", .{@tagName(stat.kind)});
            return createErrorStruct(true, error.NotSupported);
        },
    };
}

fn createErrorStruct(value: bool, err: ?anyerror) Result {
    var res: Result = .{ .Ok = value };
    if (err) |e| {
        res.Err = @errorName(e);
        std.debug.print("YYYYYYYYYYYYY: {s}\n", .{@errorName(e)});
        const g = ErrorsEnum.getError(0, e);
        std.debug.print("HHHH: {any}, typeOf({})\n", .{ g, @TypeOf(g) });
        if (g == error.FileNotOpen) {
            std.debug.print("EXISTS: {any}\n", .{g});
        }
    }
    return res;
}

pub fn createDir(dir: []const u8) Result {
    const cwd = getCWD();
    var res: Result = .{};
    cwd.makeDir(dir) catch |e| {
        return createErrorStruct(false, e);
    };
    res.Ok = true;
    return res;
}

pub fn createFile(dir: []const u8, fileName: []const u8) !void {
    var dirIter = try getCWD().openDir(dir, .{ .access_sub_paths = true, .iterate = true });
    defer {
        dirIter.close();
    }
    const file = try dirIter.createFile(fileName, .{});
    defer file.close();
}

pub fn createFile2(dir: []const u8, fileName: []const u8) !fs.File {
    var dirIter = try getCWD().openDir(dir, .{ .access_sub_paths = true, .iterate = true });
    defer {
        dirIter.close();
    }
    return try dirIter.createFile(fileName, .{});
}

pub fn concatStrings(allocator: std.mem.Allocator, a: []const u8, b: []const u8) ![]u8 {
    var bytes = try allocator.alloc(u8, a.len + b.len);
    std.mem.copyForwards(u8, bytes, a);
    std.mem.copyForwards(u8, bytes[a.len..], b);
    return bytes;
}

pub fn openDir(dir: []const u8) !fs.Dir {
    return try getCWD().makeOpenPath(dir, .{ .access_sub_paths = true, .iterate = true });
}
