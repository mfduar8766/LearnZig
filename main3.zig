const std = @import("std");
const gpa = std.mem.Allocator;
const Stringer = @import("./types.zig").Stringger;
const StringgerPointer = @import("./types.zig").StringgerPointerCasting;
const UserPtrImpl = @import("./types.zig").UserPointerImpl;

const Foo = struct {
    s: []u8,

    // When a type needs to initiaize resources, such as allocating memeory it is convention to do it in an init method
    fn init(alloc: std.mem.Allocator, s: []u8) !*Foo {
        const foo_ptr = try alloc.create(Foo); // create is used for a SINGLE VALUE
        errdefer alloc.destroy(foo_ptr);
        foo_ptr.s = try alloc.alloc(u8, s.len); // used for N values allocate len of s on the heap
        std.mem.copyForwards(u8, foo_ptr.s, s);
        // OR: foo_ptr.s = try alloc.dupe(u8, s);
        return foo_ptr;
    }
    fn deInit(self: *Foo, alloc: std.mem.Allocator) void {
        alloc.free(self.s); // works on slices allocated with alloc
        alloc.destroy(self); // works on pointers allocated with create
    }
};

const User = struct {
    allocator: std.mem.Allocator,
    id: usize,
    email: []u8,
    fn init(allocator: std.mem.Allocator, id: usize, email: []const u8) !User {
        return .{ .allocator = allocator, .id = id, .email = try allocator.dupe(u8, email) };
    }
    fn deInit(self: *User) void {
        self.allocator.free(self.email);
    }
};

const UserData = struct {
    map: std.AutoHashMap(usize, User),
    fn init(allocator: std.mem.Allocator) UserData {
        return .{ .map = std.AutoHashMap(usize, User).init(allocator) };
    }
    fn deInit(self: *UserData) void {
        self.map.deinit();
    }
    fn get(self: UserData, id: usize) ?User {
        return self.map.get(id);
    }
    fn put(self: *UserData, user: User) !void {
        try self.map.put(user.id, user);
    }
    fn delete(self: *UserData, id: usize) ?User {
        return if (self.map.fetchRemove(id)) |kv| kv.value else null;
    }
};

fn tuples() !void {
    // tuples are annonymous structs
    const tupleA: struct { u8, bool } = .{ 42, true };
    std.debug.print("tupleA: {any}, TypeOf({})\n", .{ tupleA, @TypeOf(tupleA) });

    // you can index tuples and get the len
    std.debug.print("tupleA Len({d}), tupleA[0]: {}\n", .{ tupleA.len, tupleA[0] });

    // you can access fields with @""
    std.debug.print("tupleA.@\"0\":{}\n", .{tupleA.@"0"});

    // you can concatenate tuples
    const tupleB: struct { f16, i32 } = .{ 3.14, -42 };
    const tupleC = tupleA ++ tupleB;
    std.debug.print("tupleA + tupleB: {any}\n", .{tupleC});

    // if all the fields are of same type you can concatenate arrays with tuples OF SAME TYPE
    const array: [3]u8 = .{ 1, 2, 3 };
    // tuple array
    const tupleD = .{ 4, 5, 6 };
    const res = array ++ tupleD;
    std.debug.print("Res: {any}, @TypeOf({})\n", .{ res, @TypeOf(res) });

    // you can iterate tuples using an inline for loop
    inline for (tupleC, 0..) |value, index| {
        std.debug.print("For loop tuple value: {any}, idx: {d}, @TypeOf({})\n", .{ value, index, @TypeOf(value) });
    }

    // tuples also support duplication
    const tupleE = tupleA ** 4;
    std.debug.print("tupleE: {any}\n", .{tupleE});
}

fn arrayList() !void {
    // ArrayList
    var gpaAlloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpaAlloc.deinit();

    // create a new empty list len == 0 && capacity == 0
    var arrList = std.ArrayList(u8).init(gpaAlloc.allocator());
    defer arrList.deinit();

    for ("Hello World") |value| {
        try arrList.append(value);
    }
    std.debug.print("List: {any}\n", .{arrList});
    try arrList.append('\n');
    _ = arrList.pop();
    std.debug.print("List after pop: {any}\n", .{arrList});

    // use it like a writer if its a u8 list
    const writter = arrList.writer();
    _ = try writter.print("list writting to list: {}\n", .{42});
    std.debug.print("list after writter: {any}\n", .{arrList});
    printList(arrList);
    std.debug.print("\n", .{});

    // use it like an iterator
    while (arrList.popOrNull()) |byte| std.debug.print("{c}", .{byte});
    std.debug.print("\n\n", .{});

    // appens slice
    try arrList.appendSlice("Hello World!");
    printList(arrList);

    _ = arrList.orderedRemove(5); // O(n)
    printList(arrList);

    _ = arrList.swapRemove(5); //O(1)
    printList(arrList);

    // you can clear the list and obtain a owned slice of it which MUST be freed resets list to an empty list passing ownership to the slices const
    const slice = try arrList.toOwnedSlice();
    defer gpaAlloc.allocator().free(slice);
    printList(arrList);

    arrList = try std.ArrayList(u8).initCapacity(gpaAlloc.allocator(), 12);
    for ("Hello") |value| arrList.appendAssumeCapacity(value);
    std.debug.print("list len:{}, cap:{}\n", .{ arrList.items.len, arrList.capacity });
    printList(arrList);

    const bytes = try gatherBytes(gpaAlloc.allocator(), "Hey There!!");
    defer gpaAlloc.allocator().free(bytes);
    std.debug.print("Bytes: {any}\n", .{bytes});
}

fn hasMap(allocator: std.mem.Allocator) !void {
    var users = UserData.init(allocator);
    defer users.deInit();
    var matt = try User.init(allocator, 1, "matt_duarte07@gmail.com");
    defer matt.deInit();
    try users.put(matt);

    // creates a Set
    var set = std.AutoHashMap(usize, void).init(allocator);
    defer set.deinit();
    try set.put(5, {});
    try set.put(7, {});
    try set.put(5, {});
    try set.put(7, {});
    std.debug.print("Map Count:{any}\n", .{set.count()});
}

fn gatherBytes(allocator: std.mem.Allocator, slice: []const u8) ![]u8 {
    var list = try std.ArrayList(u8).initCapacity(allocator, slice.len);
    defer list.deinit();
    for (slice) |value| list.appendAssumeCapacity(value);
    return try list.toOwnedSlice();
}

fn printList(list: std.ArrayList(u8)) void {
    std.debug.print("list: ", .{});
    for (list.items) |value| std.debug.print("{c} ", .{value});
    std.debug.print("\n\n", .{});
}

// take an output var returning the number of bytes written into it
// The function will NOT allocate memory instead the caller will
fn catOutVarLen(a: []const u8, b: []const u8, out: []u8) usize {
    std.debug.assert(out.len >= a.len + b.len);
    std.mem.copyForwards(u8, out, a);
    std.mem.copyForwards(u8, out[a.len..], b);
    return a.len + b.len;
}

fn catOutVarSlice(a: []const u8, b: []const u8, out: []u8) []u8 {
    std.debug.assert(out.len >= a.len + b.len);
    std.mem.copyForwards(u8, out, a);
    std.mem.copyForwards(u8, out[a.len..], b);
    return out[0 .. a.len + b.len];
}

fn catAlloc(allocator: std.mem.Allocator, a: []const u8, b: []const u8) ![]u8 {
    var bytes = try allocator.alloc(u8, a.len + b.len);
    std.mem.copyForwards(u8, bytes, a);
    std.mem.copyForwards(u8, bytes[a.len..], b);
    return bytes;
}

fn printString(s: Stringer) !void {
    var buf: [256]u8 = undefined;
    const str = try s.toString(&buf);
    std.debug.print("STR:{s}\n", .{str});
}

fn printStringPointer(s: StringgerPointer) !void {
    var buf: [256]u8 = undefined;
    const str = try s.toString(&buf);
    std.debug.print("STR-PTR:{s}\n", .{str});
}

fn vectors() !void {
    // Can only be booleans, ints, floats, or pointers.
    const bools_vec_a: @Vector(3, bool) = .{ true, false, true }; // tuple literal
    const bool_array_a = [3]bool{ true, false, true };
    const bools_vec_b: @Vector(3, bool) = bool_array_a; // array coercion
    const bool_vec_c = bools_vec_a == bools_vec_b;
    std.debug.print("Bool_vec_: {any}, TypeOf({})\n", .{ bool_vec_c, @TypeOf(bool_vec_c) });
    const bool_array_b: [3]bool = bool_vec_c; // coerce back to array
    std.debug.print("Bool_Array_B: {any}, typeOf({})\n", .{ bool_array_b, @TypeOf(bool_array_b) });

    const intVecA = @Vector(3, u8){ 1, 2, 3 };
    const intVecB = @Vector(3, u8){ 4, 5, 6 };
    const intVecC = intVecA + intVecB;
    std.debug.print("IntVecC: {any}\n", .{intVecC}); // { 5, 7, 9 };

    // use @splat to turn a scaler into a vec
    const tows: @Vector(3, u8) = @splat(2);
    const intVecD = intVecA * tows;
    std.debug.print("intVecD: {any}\n", .{intVecD});

    // use @reduce to get the scaler from the vec
    // supported ops = .And, .Xor, .Min, .Max, .Mul
    const allTrues = @reduce(.And, bools_vec_a); // requires that all values are true
    std.debug.print("allTrues: {any}\n", .{allTrues});
    const orOps = @reduce(.Or, bools_vec_a);
    std.debug.print("OrOps: {any}\n", .{orOps});
    // use array indexing to get elements from vec
    std.debug.print("boolsVecA[1]:{any}\n", .{bool_array_a[1]});
}

pub fn main() !void {
    try tuples();
    try arrayList();

    var gpaAlloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpaAlloc.deinit();
    const allocator = gpaAlloc.allocator();
    try hasMap(allocator);

    // tagged union interface
    const bob = Stringer{ .user = .{
        .email = "bob@gmail.com",
        .name = "bob",
    } };
    try printString(bob);

    var user = UserPtrImpl{ .email = "bob@gmail.com", .name = "bob" };
    const stringger = user.stringger();
    try printStringPointer(stringger);

    try vectors();
}

test "catOutVarLen" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";
    var buf: [128]u8 = undefined;
    const len = catOutVarLen(hello, world, &buf);
    try std.testing.expectEqualStrings(hello ++ world, buf[0..len]);
}

test "catVarOutLenSlice" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";
    var buf: [128]u8 = undefined;
    const slice = catOutVarSlice(hello, world, &buf);
    try std.testing.expectEqualStrings(hello ++ world, slice);
}

test "catAlloc" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";
    const allocator = std.testing.allocator;
    const slice = try catAlloc(allocator, hello, world);
    defer allocator.free(slice);
    try std.testing.expectEqualStrings(hello ++ world, slice);
}
