const std = @import("std");
const Print = std.debug.print;
const Logger = @import("./logger/logger.zig").Logger;
const Utils = @import("./utils/utils.zig");
const Http = @import("./http//http.zig").Http;
const fs = std.fs;
const process = std.process;
const Types = @import("./types/types.zig");
const builtIn = @import("builtin");
const eql = std.mem.eql;
const Context = @import("./context/context.zig");
const Driver = @import("./driver//driver.zig").Driver;

// https://stackoverflow.com/questions/72122366/how-to-initialize-variadic-function-arguments-in-zig
// https://www.reddit.com/r/Zig/comments/y5b2xw/anytype_vs_comptime_t/
// https://ziggit.dev/t/format-timestamp-into-iso-8601-strings/3824
// https://www.reddit.com/r/Zig/comments/l0ne7b/is_there_a_way_of_adding_an_optional_fields_in/
// https://ziggit.dev/t/how-to-set-struct-field-with-runtime-values/2758/6
// https://www.aolium.com/karlseguin/cf03dee6-90e1-85ac-8442-cf9e6c11602a
// https://cookbook.ziglang.cc/08-02-external.html STD.IO
// BETTER CHROME URL STABLE VERSIONS https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
// https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json
// STABLE BETA ECT https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
// CHROME-DRIVER-YOUTUBE: https://www.youtube.com/watch?v=F2jMzBW1Vl4&ab_channel=RakibulYeasin
// https://joeymckenzie.tech/blog/ziggin-around-with-linked-lists
// https://w3c.github.io/webdriver/#endpoints

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // var ctx = Context.Context2(i32).init(allocator);
    // defer ctx.deInit();
    // try ctx.withValue("FOO", 33);
    // var ctx = Context.Context.init(allocator);
    // defer ctx.deInit();
    // const withValue = try ctx.withValue("FOO", "BAR");
    // Print("VALUE: {any}\n", .{ctx.getValue("FOO").?});

    var logger = try Logger.init("Logs");
    try logger.info("main program running...", null);
    var driver = try Driver.init(allocator, logger, .{});
    try driver.launchWindow("https://jsonplaceholder.typicode.com/");
    defer {
        _ = gpa.deinit();
        logger.closeDirAndFiles();
    }

    // var buf: [9945236]u8 = undefined;
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    // var arrList = try std.ArrayList(u8).initCapacity(fba.allocator(), buf.len);
    // for (body2) |value| {
    //     try arrList.append(value);
    // }
    // var cwd = Utils.getCWD();
    // var dir = try cwd.makeOpenPath("chromeDriver", .{ .access_sub_paths = true, .iterate = true });
    // defer dir.close();
    // for (arrList.items) |value| {
    //     try dir.writeFile(.{ .data = value, .sub_path = "/", .flags = .{} });
    // }

    // const fileBuf: [body2.len]u8 = undefined;
    // const fileArray = std.ArrayList(u8).initCapacity(allocator, body2.len);
    // const cwd = Utils.getCWD();

    // Print("DOWNLOAD: {s}\n", .{body2});

    // const res = try std.json.parseFromSlice(Types.ChromeDriverResponse, allocator, body, .{ .ignore_unknown_fields = true });
    // defer res.deinit();
    // const drivers = res.value.channels.Stable.downloads.chromedriver;
    // for (drivers) |driver| {
    //     comptime switch (std.Target.Os.Tag) {
    //         .macos => {
    //             Print("TAG: {any}, {s}, {s}\n", .{ std.Target.Os.Tag, driver.platform, driver.url });
    //         },
    //         else => {},
    //     };
    // }

    // const CHROME_DRIVER_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json";
    // var cwd = Utils.getCWD();
    // const f = try cwd.createFile("f.sh", .{});
    // try f.chmod(777);
    // defer f.close();
    // var buf: [1024]u8 = undefined;
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    // var string = try std.ArrayList(u8).initCapacity(fba.allocator(), buf.len);
    // _ = try string.writer().write("#!/bin/bash");
    // _ = try string.writer().write("\n");
    // _ = try string.writer().write("echo \"FOO BAR BAZ YOLO\"");
    // var bufWriter = std.io.bufferedWriter(f.writer());
    // const writer = bufWriter.writer();
    // _ = try writer.print("{s}\n", .{string.items});
    // try bufWriter.flush();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();
    // const argv = [_][]const u8{
    //     "chmod",
    //     "+x",
    //     "./startChrome.sh",
    // };

    // var child = process.Child.init(&argv, allocator);
    // child.stdout_behavior = .Pipe;
    // child.stderr_behavior = .Pipe;
    // var stdout = std.ArrayList(u8).init(allocator);
    // var stderr = std.ArrayList(u8).init(allocator);
    // defer {
    //     stdout.deinit();
    //     stderr.deinit();
    // }
    // try child.spawn();
    // try child.collectOutput(&stdout, &stderr, 1024);
    // const term = try child.wait();
    // switch (term) {
    //     .Exited => |code| {
    //         if (code != 0) {
    //             Print("The following command exited with error code {any}:\n", .{code});
    //             return error.CommandFailed;
    //         }
    //     },
    //     .Signal => |sig| {
    //         Print("The following command returned signal: {any}\n", .{sig});
    //     },
    //     else => {
    //         Print("The following command terminated unexpectedly with error:{s}\n", .{stderr.items});
    //         return error.CommandFailed;
    //     },
    // }
    // Print("Out: {s}\n", .{stdout.items});

    // while (true) {
    //     var logger = try Logger.init("Logs");
    //     defer {
    //         logger.closeDirAndFiles();
    //     }
    //     try logger.info("LOG1", null);
    //     try logger.info("LOG2", null);
    //     try logger.info("LOG3", null);
    //     try logger.info("LOG4", null);
    // }
}
