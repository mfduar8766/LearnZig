const std = @import("std");
const print = std.debug.print;
const Logger = @import("./logger/logger.zig").Logger;
const Utils = @import("./utils/utils.zig");
const process = std.process;
const Driver = @import("./driver//driver.zig").Driver;
const DriverOptions = @import("./driver//types.zig").Options;

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
    var logger = try Logger.init("Logs");
    try logger.info("Main::main()::program running...", null);

    // var cwd = Utils.getCWD();
    // const buf: [1024]u8 = undefined;
    // var arrayList = try std.ArrayList(u8).initCapacity(allocator, buf.len);
    // const fileName = "startChromeDriver.sh";
    // var fileExists = true;
    // Utils.fileExists(cwd, fileName) catch |e| {
    //     try logger.warn("Driver::openDriver()::error:", @errorName(e));
    //     fileExists = false;
    // };
    // if (fileExists) {
    //     try cwd.deleteFile(fileName);
    // }
    // var startChromeDriver = try cwd.createFile(fileName, .{});
    // try startChromeDriver.chmod(777);
    // _ = try arrayList.writer().write("#!/bin/bash\n");
    // _ = try arrayList.writer().write("cd \"chromeDriver/chromedriver-mac-x64/\"\n");
    // _ = try arrayList.writer().write("chmod +x ./chromedriver\n");
    // _ = try arrayList.writer().write("./chromedriver --port=42069 --log-path=/Users/matheusduarte/Desktop/LearnZig/Logs/2024_12_30.log\n");
    // var bufWriter = std.io.bufferedWriter(startChromeDriver.writer());
    // const writer = bufWriter.writer();
    // _ = try writer.print("{s}\n", .{arrayList.items});
    // try bufWriter.flush();

    // const argv = [_][]const u8{
    //     "chmod",
    //     "+x",
    //     "./startChromeDriver.sh",
    // };
    // try Utils.executeCmds(3, allocator, &argv);
    // const arg2 = [_][]const u8{
    //     "./startChromeDriver.sh",
    // };
    // try Utils.executeCmds(1, allocator, &arg2);

    var driver = try Driver.init(allocator, logger, DriverOptions{ .chromeDriverExecPath = "/Users/matheusduarte/Desktop/LearnZig/chromeDriver/chromedriver-mac-x64/chromedriver", .chromeDriverPort = 4444, .chromeDriverVersion = "Stable" });
    try driver.launchWindow("https://jsonplaceholder.typicode.com/");
    // options.deinit();
    defer {
        // startChromeDriver.close();
        // arrayList.deinit();
        logger.closeDirAndFiles();
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Main::main()::leaking memory exiting program...");
    }
}
// var args = process.args();
// const options = try Utils.readCmdArgs(allocator, &args);
// print("GG: {s}\n", .{options.value.chromeDriverExecPath.?});
// var optionsFile: []const u8 = "";
// while (args.next()) |a| {
//     var splitArgs = std.mem.splitAny(u8, a, "=");
//     while (splitArgs.next()) |next| {
//         if (std.mem.endsWith(u8, next, ".json")) {
//             optionsFile = next;
//             break;
//         }
//     }
// }
// if (optionsFile.len == 0) {
//     @panic("Utils::readCmdArgs()::no options.json file passed in, exiting program...");
// }
// const cwd = Utils.getCWD();
// var buf: [2000]u8 = undefined;
// const content = try cwd.readFile(optionsFile, &buf);
// if (content.len == 0) {
//     @panic("Utils::readCmdArgs()::options.json file is empty, exiting program...");
// }
// const options = try std.json.parseFromSlice(DriverOptions, allocator, content, .{ .ignore_unknown_fields = true });
