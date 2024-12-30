const std = @import("std");
const Driver = @import("../driver/driver.zig").Driver;
const DriverOptions = @import("../driver//types.zig").Options;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var driver = try Driver.init(gpa.allocator(), undefined, DriverOptions{ .chromeDriverExecPath = "/Users/matheusduarte/Desktop/LearnZig/chromeDriver/chromedriver-mac-x64/chromedriver", .chromeDriverPort = 4444, .chromeDriverVersion = "Stable" });
    try driver.launchWindow("https://jsonplaceholder.typicode.com/");
    defer {
        driver.deInit();
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Main::main()::leaking memory exiting program...");
    }
}
