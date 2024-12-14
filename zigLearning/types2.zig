const std = @import("std");

const User = struct {
    name: []const u8,
    email: []const u8,
    // implementation of toString(...)
    fn toString(self: User, buf: []u8) ![]u8 {
        return std.fmt.bufPrint(buf, "User(name: {[name]s}, email: {[email]s})", self);
    }
};

// Tagged Union Interface - Easiest way and most performant way to implement but its a closed interface
pub const Stringger = union(enum) {
    user: User,
    // Dispatch of the implementation
    pub fn toString(self: Stringger, buf: []u8) ![]u8 {
        return switch (self) {
            inline else => |it| it.toString(buf),
        };
    }
};

// Pointer casting interface
pub const StringgerPointerCasting = struct {
    ptr: *anyopaque, // a type that is type erasure which means it can take any type and we lose details about this type like an interface{} type in go. Does NOT have a known size.
    toStringFn: *const fn (*anyopaque, []u8) anyerror![]u8,
    pub fn toString(self: StringgerPointerCasting, buf: []u8) anyerror![]u8 {
        return self.toStringFn(self.ptr, buf);
    }
};

pub const UserPointerImpl = struct {
    email: []const u8,
    name: []const u8,
    pub fn toString(ptr: *anyopaque, buf: []u8) ![]u8 {
        const self: *UserPointerImpl = @ptrCast(@alignCast(ptr));
        return std.fmt.bufPrint(buf, "User(name: {[name]s}, email: {[email]s})", self.*);
    }
    pub fn stringger(self: *UserPointerImpl) StringgerPointerCasting {
        return .{
            .ptr = self,
            .toStringFn = UserPointerImpl.toString,
        };
    }
};
