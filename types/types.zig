const std = @import("std");
const Utils = @import("../utils/utils.zig");

pub const LogLevels = enum(u2) {
    INFO = 0,
    WARNING = 1,
    ERROR = 2,
    FATAL = 3,
    pub fn get(key: u2) []const u8 {
        return switch (key) {
            0 => "INFO",
            1 => "WARNING",
            2 => "ERROR",
            3 => "FATAL",
        };
    }
};

pub const RequestUrlPaths = enum(u8) {
    DELETE_SESSION,
    STATUS,
    TIME_OUTS,
    SET_TIME_OUTS,
    NAVIGATE_TO,
    GET_CURR_URL,
    GET_WINDOW_HANDLE,
    CLOSE_WINDOW,
    NEW_WINDOW,
    FIND_ELEMENT,
    pub fn getUrlPath(allocator: std.mem.Allocator, key: u8, url: []const u8, sessionID: []const u8) []const u8 {
        return switch (key) {
            0 => try Utils.concatStrings(allocator, url, sessionID),
            1 => "ttp://localhost:4444/",
            2 => "",
            3 => "",
            4 => "",
            5 => "",
            6 => "",
            7 => "",
            8 => "",
            9 => "",
            else => "",
        };
    }
};

pub const ErrorTypes = enum(u8) {
    FileNotFound,
    AccessDenied,
    NameTooLong,
    NotSupported,
    NotDir,
    SymLinkLoop,
    InputOutput,
    FileTooBig,
    IsDir,
    ProcessFdQuotaExceeded,
    SystemFdQuotaExceeded,
    NoDevice,
    SystemResources,
    NoSpaceLeft,
    FileSystem,
    BadPathName,
    DeviceBusy,
    SharingViolation,
    PipeBusy,
    NotLink,
    PathAlreadyExists,
    pub fn getErrorName(key: u8) [:0]const u8 {
        return switch (key) {
            0 => @errorName(error.FileNotFound),
            1 => "WARNING",
            2 => "ERROR",
            3 => "FATAL",
        };
    }
    // pub fn get(name: [:0]const u8) bool {
    //     var gpaAlloc = std.heap.GeneralPurposeAllocator(.{}){};
    //     defer _ = gpaAlloc.deinit();
    //     const allocator = gpaAlloc.allocator();
    //     var set = std.AutoHashMap(usize, void).init(allocator);
    //     defer set.deinit();
    //     try set.put(error.FileNotFound, true);
    // }
};

pub const PlatForms = enum(u4) {
    LINUX,
    MAC_ARM_64,
    MAC_X64,
    WIN_32,
    WIN_64,
    pub fn getOS(key: u4) []const u8 {
        return switch (key) {
            0 => "linux64",
            1 => "mac-arm64",
            2 => "mac-x64",
            3 => "win32",
            4 => "win64",
            else => "UNKNOWN",
        };
    }
};

pub const ChromeCapabilities = struct {
    const Self = @This();
    capabilities: Capabilities,
};

pub const Capabilities = struct {
    acceptInsecureCerts: bool = true,
};

pub const ChromeDriverResponse = struct {
    timestamp: []u8,
    channels: Channels,
};

const Channels = struct {
    Stable: Stable,
    Beta: Beta,
    Dev: Dev,
    Canary: Canary,
};

const Stable = struct {
    channel: []u8,
    version: []u8,
    revision: []u8,
    downloads: Downloads,
};

const Beta = struct {
    channel: []u8,
    version: []u8,
    revision: []u8,
    downloads: Downloads,
};

const Dev = struct {
    channel: []u8,
    version: []u8,
    revision: []u8,
    downloads: Downloads,
};

const Canary = struct {
    channel: []u8,
    version: []u8,
    revision: []u8,
    downloads: Downloads,
};

const Downloads = struct {
    chrome: []Chrome,
    chromedriver: []Chromedriver,
    // chromeHeadlessShell: []ChromeHeadlessShell
};

const Chrome = struct {
    platform: []u8,
    url: []u8,
};

const Chromedriver = struct {
    platform: []u8,
    url: []u8,
};

const ChromeHeadlessShell = struct {
    platform: []u8,
    url: []u8,
};

// pub const ChromeApiResponse = struct {
//     timestamp: []u8,
//     versions: []ChromeVersions,
// };

// const ChromeVersions = struct {
//     version: []u8,
//     revision: []u8,
//     downloads: ChromeDownloads,
// };

// const ChromeDownloads = struct {
//     chrome: []Chrome,
// };

// const Chrome = struct {
//     platform: []u8,
//     url: []u8,
// };
