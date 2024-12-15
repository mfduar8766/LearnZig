const std = @import("std");
const http = std.http;
const Client = std.http.Client;
const Uri = std.Uri;
const RequestOptions = std.http.Client.RequestOptions;
const Types = @import("/types.zig");

pub const Http = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;
    const ReqOptions = struct {
        maxReaderSize: usize = 2 * 1042 * 1024,
    };
    allocator: Allocator,
    client: std.http.Client,
    reqOpts: ReqOptions,
    host: []const u8 = "http://localhost:4444/session",
    sessionID: []const u8 = "",

    pub fn init(allocator: std.mem.Allocator, reqOpts: ReqOptions) Self {
        const client = Client{ .allocator = allocator };
        return Self{
            .allocator = allocator,
            .client = client,
            .reqOpts = reqOpts,
        };
    }
    pub fn deinit(self: *Self) void {
        self.client.deinit();
    }
    pub fn get(self: *Self, url: []const u8, options: RequestOptions, maxReaderSize: ?usize) ![]u8 {
        const uri = try Uri.parse(url);
        var req = try self.client.open(.GET, uri, options);
        defer req.deinit();

        try req.send();
        try req.finish();
        try req.wait();

        std.debug.print("REQ.STATUS: {d} LEN: {any}\n", .{ req.response.status, req.response.content_length });
        if (req.response.status != http.Status.ok) {
            return http.Client.RequestError.NetworkUnreachable;
        }
        var maxSize: usize = self.reqOpts.maxReaderSize;
        if (maxReaderSize) |max| {
            maxSize = max;
        }
        const body = try req.reader().readAllAlloc(self.allocator, maxSize);
        defer self.allocator.free(body);
        std.debug.print("BODY.LEN:{d} READER.LEM:{d}\n", .{ body.len, self.reqOpts.maxReaderSize });
        return body;
    }
    pub fn post(self: *Self, url: []const u8, options: RequestOptions) ![]u8 {
        const uri = try Uri.parse(url);
        var req = try self.client.open(.POST, uri, options);
        defer req.deinit();

        try req.send();
        try req.finish();
        try req.wait();

        std.debug.print("REQ.POST.STATUS: {d} LEN: {any}\n", .{ req.response.status, req.response.content_length });
        if (req.response.status != http.Status.ok) {
            return http.Client.RequestError.NetworkUnreachable;
        }
        const body = try req.reader().readAllAlloc(self.allocator, self.reqOpts.maxReaderSize);
        defer self.allocator.free(body);
        std.debug.print("Len:{d}\n", .{body.len});
        return body;
    }
    fn setRequestUrlSuffix(self: *Self, key: u8) ![]const u8 {
        return try Types.RequestUrlPaths.getUrlPath(self.allocator, key, self.host, self.sessionID);
    }
};
