const std = @import("std");
const http = std.http;
const Client = std.http.Client;
const Uri = std.Uri;
const RequestOptions = std.http.Client.RequestOptions;

pub const Http = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;
    const ReqOptions = struct {
        maxReaderSize: usize,
    };
    allocator: Allocator,
    client: std.http.Client,
    reqOpts: ReqOptions,

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
    pub fn get(self: *Self, url: []const u8, options: RequestOptions) ![]u8 {
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
        const body = try req.reader().readAllAlloc(self.allocator, self.reqOpts.maxReaderSize);
        defer self.allocator.free(body);
        std.debug.print("{d}\n", .{body.len});
        return body;
    }
};
