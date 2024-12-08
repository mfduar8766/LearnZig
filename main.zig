const std = @import("std");
const Print = std.debug.print;
const expect = std.testing.expect;
const time = std.time;
const os = std.os;
const fs = std.fs;
const eql = std.mem.eql;
const assert = std.debug.assert;
const Logger = @import("./logger.zig").Logger;
const Utils = @import("./utils.zig");
const io = std.io;

// https://stackoverflow.com/questions/72122366/how-to-initialize-variadic-function-arguments-in-zig
// https://www.reddit.com/r/Zig/comments/y5b2xw/anytype_vs_comptime_t/
// https://ziggit.dev/t/format-timestamp-into-iso-8601-strings/3824
// https://www.reddit.com/r/Zig/comments/l0ne7b/is_there_a_way_of_adding_an_optional_fields_in/
// https://ziggit.dev/t/how-to-set-struct-field-with-runtime-values/2758/6
// https://www.aolium.com/karlseguin/cf03dee6-90e1-85ac-8442-cf9e6c11602a

const CHROME_DRIVER_URL: []const u8 = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json";
const SELENIUM_STAND_ALONE_JAR: []const u8 = "https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar";

const Place = struct {
    lat: f32,
    long: f32,
};

const Person = struct {
    name: []const u8,
    age: u8,
    height: u8,
    const Self = @This();

    pub fn init(name: []const u8, age: u8, height: u8) Self {
        return .{ .name = name, .age = age, .height = height };
    }
};

pub const Location = struct {
    lat: f32,
    lon: f32,

    pub fn jsonStringify(self: Location, ws: anytype) !void {
        try ws.beginObject();
        try ws.objectField("lat");
        try ws.write(self.lat);
        try ws.objectField("lon");
        try ws.write(self.lon);
        try ws.endObject();
    }
};

pub const Person2 = struct {
    name: []const u8,
    location: Location,

    pub fn jsonStringify(self: Person2, ws: anytype) !void {
        try ws.beginObject();
        try ws.objectField("name");
        try ws.write(self.name);
        try ws.objectField("location");
        try ws.write(self.location);
        try ws.endObject();
    }
};

pub fn main() !void {
    // WRITES AN ARRAY TO THE FILE
    // const person1 = Person.init("Alice", 25, 170);
    // const person2 = Person.init("Bob", 30, 180);
    // const person3 = Person.init("Charlie", 35, 190);
    // const persons = &.{ person1, person2, person3 };
    // const allocator = std.heap.page_allocator;
    // const string = try std.json.stringifyAlloc(allocator, persons, .{ .emit_strings_as_arrays = false });
    // var file = try fs.cwd().createFile("./persons.json", .{});
    // defer file.close();
    // _ = try file.writeAll(string);

    // const person = Person2{
    //     .name = "Zig",
    //     .location = Location{
    //         .lat = 12.34,
    //         .lon = 56.78,
    //     },
    // };
    // var out = std.ArrayList(u8).init(std.heap.page_allocator);
    // defer out.deinit();
    // try std.json.stringify(person, .{ .whitespace = .indent_2 }, out.writer());
    // std.debug.print("\n{s}\n", .{out.items});

    // var buf: [1024]u8 = undefined;
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    // var string = std.ArrayList(u8).init(fba.allocator());
    // try std.json.stringify(person, .{}, string.writer());

    // const cwd = Utils.getCWD();
    // var dirIter = try cwd.openDir("Logs", .{ .access_sub_paths = true, .iterate = true });
    // const file = try dirIter.openFile("2024_12_7.log", .{ .mode = .read_write });
    // defer dirIter.close();
    // defer file.close();
    // var bufWriter = io.bufferedWriter(file.writer());
    // const writer = bufWriter.writer();
    // _ = try writer.print("{s}\n", .{string.items});
    // try bufWriter.flush();
    // _ = try writer.print("{s}\n", .{string.items});
    // try bufWriter.flush();

    // var buf: [100]u8 = undefined;
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    // var string = std.ArrayList(u8).init(fba.allocator());
    // try std.json.stringify(x, .{}, string.writer());
    // Print("STR: {s}\n", .{string.items});

    // const y = Place{
    //     .lat = 51.22,
    //     .long = -0.66,
    // };
    // var buf2: [100]u8 = undefined;
    // var fba2 = std.heap.FixedBufferAllocator.init(&buf2);
    // var string2 = std.ArrayList(u8).init(fba2.allocator());
    // try std.json.stringify(y, .{}, string2.writer());
    // Print("STR2: {s}\n", .{string2.items});

    var logger = try Logger.init("Logs/");
    defer {
        logger.closeDirAndFiles();
    }
    // try logger.info("LOG1", null);
    // try logger.info("LOG2", null);
    // try logger.info("LOG3", null);
    // try logger.info("LOG4", null);
    // try logger.info("SOME DATA", string2.items);
}
