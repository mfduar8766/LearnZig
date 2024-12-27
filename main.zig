const std = @import("std");
const print = std.debug.print;
const Logger = @import("./logger/logger.zig").Logger;
const Utils = @import("./utils/utils.zig");
const process = std.process;
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
    var args = process.args();
    const driverOptions = try Utils.readCmdArgs(allocator, &args);
    var logger = try Logger.init("Logs");
    try logger.info("Main::main()::program running...", null);
    var driver = try Driver.init(allocator, logger, driverOptions.value);
    driverOptions.deinit();
    try driver.launchWindow("https://jsonplaceholder.typicode.com/");
    defer {
        _ = gpa.deinit();
        logger.closeDirAndFiles();
    }
}
