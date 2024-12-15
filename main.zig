const std = @import("std");
const Print = std.debug.print;
const Logger = @import("./logger.zig").Logger;
const Utils = @import("./utils.zig");
const Http = @import("./http.zig").Http;
const fs = std.fs;
const process = std.process;
const Types = @import("./types.zig");

// https://www.google.com/search?q=automate+chromedriver+without+selenium&sca_esv=86a88d896bcf14c1&rlz=1C5CHFA_enUS772US772&ei=CfNdZ4bfE6fiwN4P9rCLuA4&ved=0ahUKEwjGh8TtlKiKAxUnMdAFHXbYAucQ4dUDCBA&uact=5&oq=automate+chromedriver+without+selenium&gs_lp=Egxnd3Mtd2l6LXNlcnAiJmF1dG9tYXRlIGNocm9tZWRyaXZlciB3aXRob3V0IHNlbGVuaXVtMgYQABgWGB4yBhAAGBYYHjILEAAYgAQYhgMYigUyCxAAGIAEGIYDGIoFMgsQABiABBiGAxiKBTIIEAAYgAQYogQyBRAAGO8FMggQABiABBiiBEi6cFD0DljSbnAIeACQAQCYAXSgAb0cqgEENDAuNLgBA8gBAPgBAZgCL6ACkhqoAhTCAgoQABiwAxjWBBhHwgILEAAYgAQYkQIYigXCAgoQABiABBhDGIoFwgINEAAYgAQYsQMYQxiKBcICDhAuGIAEGLEDGNEDGMcBwgILEC4YgAQYsQMYgwHCAggQABiABBixA8ICERAuGIAEGLEDGNEDGIMBGMcBwgIFEAAYgATCAgsQABiABBixAxiDAcICDhAAGIAEGLEDGIMBGIoFwgIaEC4YgAQYsQMYgwEYlwUY3AQY3gQY4ATYAQHCAggQLhiABBixA8ICDhAuGIAEGLEDGMcBGK8BwgILEC4YgAQY0QMYxwHCAg0QABiABBixAxhGGPkBwgInEAAYgAQYsQMYRhj5ARiXBRiMBRjdBBhGGPkBGPQDGPUDGPYD2AEBwgIUEAAYgAQYkQIYtAIYigUY6gLYAQLCAh0QABiABBi0AhjUAxjlAhi3AxiKBRjqAhiKA9gBAsICEBAAGAMYtAIY6gIYjwHYAQHCAgoQLhiABBhDGIoFwgIFEC4YgATCAhAQLhiABBjRAxhDGMcBGIoFwgIOEC4YgAQYxwEYjgUYrwHCAgsQLhiABBjHARivAcICERAuGIAEGJECGNEDGMcBGIoFwgIHEAAYgAQYDcICBhAAGA0YHsICCBAAGBYYChgewgIIEAAYogQYiQWYAwXxBZASH6MFj0bWiAYBkAYIugYGCAEQARgUugYECAIYB5IHBDQzLjSgB5LzAg&sclient=gws-wiz-serp#fpstate=ive&vld=cid:a3860590,vid:F2jMzBW1Vl4,st:0
// https://stackoverflow.com/questions/72122366/how-to-initialize-variadic-function-arguments-in-zig
// https://www.reddit.com/r/Zig/comments/y5b2xw/anytype_vs_comptime_t/
// https://ziggit.dev/t/format-timestamp-into-iso-8601-strings/3824
// https://www.reddit.com/r/Zig/comments/l0ne7b/is_there_a_way_of_adding_an_optional_fields_in/
// https://ziggit.dev/t/how-to-set-struct-field-with-runtime-values/2758/6
// https://www.aolium.com/karlseguin/cf03dee6-90e1-85ac-8442-cf9e6c11602a
// https://cookbook.ziglang.cc/08-02-external.html
// BETTER CHROME URL STABLE VERSIONS https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
// https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json
// STABLE BETA ECT https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json

pub fn main() !void {
    // const host: []const u8 = "http://localhost:4444/sesion";
    const CHROME_DRIVER_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const serverHeaderBuf: []u8 = try allocator.alloc(u8, 1024 * 8);
    defer allocator.free(serverHeaderBuf);
    var req = Http.init(allocator, .{ .maxReaderSize = 8696 });
    defer req.deinit();
    _ = try req.get(CHROME_DRIVER_URL, .{ .server_header_buffer = serverHeaderBuf }, undefined);
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
