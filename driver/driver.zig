const std = @import("std");
const Http = @import("../http//http.zig").Http;
const Logger = @import("../logger//logger.zig").Logger;
const builtIn = @import("builtin");
const Types = @import("../types/types.zig");
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;
const Utils = @import("../utils/utils.zig");
const endsWith = std.mem.endsWith;

pub const Driver = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;
    const Options = struct {
        chromeDriverPath: ?[]const u8 = null,
        chromeDriverPort: ?i32 = null,
        chromeDriverVersion: ?[]const u8 = null,
    };
    const CHROME_DRIVER_DOWNLOAD_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json";
    chromeDriverRestURL: []const u8 = "http://localhost:{}/session",
    chromeDriverPort: i32 = 4444,
    allocator: Allocator,
    logger: Logger,
    chromeDriverVersion: []const u8 = Types.ChromeDriverVersion.getDriverVersion(0),
    chromeDriverPath: []const u8 = "",
    sessionID: []const u8 = "",

    pub fn init(allocator: Allocator, logger: Logger, options: ?Options) !Self {
        var driver = Driver{ .allocator = allocator, .logger = logger };
        try driver.checkOptions(options);
        try driver.downloadChromeDriverVersionInformation();
        return driver;
    }
    pub fn launchWindow(self: *Self, url: []const u8) !void {
        try self.logger.info("Driver::launchWindow()::navigating to:", url);
    }
    fn checkOptions(self: *Self, options: ?Options) !void {
        if (options) |op| {
            if (op.chromeDriverPort) |port| {
                self.chromeDriverPort = port;
            }
            if (op.chromeDriverVersion) |version| {
                const stable = Types.ChromeDriverVersion.getDriverVersion(0);
                const beta = Types.ChromeDriverVersion.getDriverVersion(1);
                const dev = Types.ChromeDriverVersion.getDriverVersion(2);
                const isCorrecrtVersion = (eql(u8, version, stable) or eql(u8, version, beta) or eql(u8, version, dev));
                if (!isCorrecrtVersion) {
                    try self.logger.warn("Driver::init()::incorrect chromeDeiver version specified defaulting to Stable...", null);
                } else {
                    self.chromeDriverVersion = op.chromeDriverVersion.?;
                }
            }
            if (op.chromeDriverPath) |path| {
                if (path.len > 0) self.chromeDriverPath = path;
            }
        }
    }
    fn downloadChromeDriverVersionInformation(self: *Self) !void {
        const serverHeaderBuf: []u8 = try self.allocator.alloc(u8, 1024 * 8);
        var req = Http.init(self.allocator, .{ .maxReaderSize = 8696 });
        const body = try req.get(CHROME_DRIVER_DOWNLOAD_URL, .{ .server_header_buffer = serverHeaderBuf }, undefined);
        var buf: [1024 * 8]u8 = undefined;
        const numAsString = try std.fmt.bufPrint(&buf, "{}", .{body.len});
        try self.logger.info("Driver::downloadChromeDriver()::successfully downloaded btypes", numAsString);
        const res = try std.json.parseFromSlice(Types.ChromeDriverResponse, self.allocator, body, .{ .ignore_unknown_fields = true });
        try self.downoadChromeDriverZip(res.value);
        defer {
            self.allocator.free(serverHeaderBuf);
            self.allocator.free(body);
            req.deinit();
            res.deinit();
        }
    }
    fn downoadChromeDriverZip(self: *Self, res: Types.ChromeDriverResponse) !void {
        var chromeDriverURL: []const u8 = "";
        const tag: []const u8 = getOsType();
        if (tag.len == 0 or eql(u8, tag, "UNKNOWN")) {
            try self.logger.fatal("Driver::downoadChromeDriverZip()::cannot find OSType", tag);
            @panic("Driver::downoadChromeDriverZip()::osType does not exist exiting program...");
        }
        for (res.channels.Stable.downloads.chromedriver) |driver| {
            if (eql(u8, driver.platform, tag)) {
                chromeDriverURL = driver.url;
                break;
            }
        }
        var arrayList = try std.ArrayList([]const u8).initCapacity(self.allocator, 100);
        defer arrayList.deinit();
        var t = std.mem.split(u8, chromeDriverURL, "/");
        while (t.next()) |value| {
            try arrayList.append(value);
        }
        const chromeDriverFileName = arrayList.items[arrayList.items.len - 1];
        const serverHeaderBuf: []u8 = try self.allocator.alloc(u8, 1024 * 8);
        defer self.allocator.free(serverHeaderBuf);
        var req = Http.init(self.allocator, .{ .maxReaderSize = 10679494 });
        defer req.deinit();
        const body = try req.get(chromeDriverURL, .{ .server_header_buffer = serverHeaderBuf }, null);
        defer self.allocator.free(body);
        const file = try std.fs.cwd().createFile(
            chromeDriverFileName,
            .{ .read = true },
        );
        defer file.close();
        try file.writeAll(body);
        try file.seekTo(0);
    }
    fn getOsType() []const u8 {
        return switch (builtIn.os.tag) {
            .macos => {
                const archType = builtIn.target.os.tag.archName(builtIn.cpu.arch);
                if (startsWith(u8, archType, "x")) {
                    return Types.PlatForms.getOS(2);
                }
                return Types.PlatForms.getOS(1);
            },
            else => "",
        };
    }
    fn setRequestUrlSuffix(self: *Self, key: u8) ![]const u8 {
        return try Types.RequestUrlPaths.getUrlPath(self.allocator, key, self.host, self.sessionID);
    }
};
