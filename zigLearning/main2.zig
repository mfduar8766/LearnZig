const std = @import("std");
const Print = std.debug.print;
const expect = std.testing.expect;
pub const Vec = struct {
    x: f32,
    y: f32,
    z: f32 = 13.0, // defaults
    pub fn swap(self: *Vec) void {
        const temp = self.x;
        self.x = self.y;
        self.y = temp;
    }
};

fn words() void {
    const letter: u8 = 'a';
    const wordArray = [5]u8{ 'H', 'E', 'L', 'L', 'O' };
    const word: []const u8 = "Hello";
    Print("Letter: {}, wordArray: {s}, word: {s}\n", .{ letter, wordArray, word });
}

// NameSpace = Struct with no fields
const NameSpace = struct {
    const pi: f64 = 3.14;
    var count: usize = 0;
};

const Point = struct {
    x: f32 = 0,
    y: f32 = 0,
    // NameSpace func
    fn new(x: f32, y: f32) Point {
        return .{ .x = x, .y = y };
    }
    // Method
    fn distance(self: Point, other: Point) f32 {
        const diffX = other.x - self.x;
        const diffY = other.y - self.y;
        return @sqrt(diffX * diffX + diffY * diffY);
    }
};

fn incrementX(x: *f32) void {
    x.* += 1;
}

// const Suit = enum {
//     clubs,
//     spades,
//     diamonds,
//     hearts,
//     pub fn isClubs(self: Suit) bool {
//         return self == Suit.clubs;
//     }
// };

fn While_With_Continue_Expression() i8 {
    var sum: i8 = 0;
    var i: i8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    Print("While_With_Continue_Expression()::sum:{d}\n", .{sum});
    return sum;
}

fn While_With_Continue() i8 {
    var sum: i8 = 0;
    var i: i8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) continue;
        sum += i;
    }
    Print("While_With_Continue()::sum:{d}\n", .{sum});
    return sum;
}

fn While_With_Break() i8 {
    var sum: i8 = 0;
    var i: i8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) break;
        sum += i;
    }
    Print("While_With_Break()::sum:{d}\n", .{sum});
    return sum;
}

fn For_Loops() void {
    const sttrings = [_]u8{ 'a', 'b', 'c' };
    for (sttrings, 0..) |char, index| {
        Print("For_Loops()::CharU8:{d}, Index:{d}\n", .{ char, index });
    }
}

// Defer - When we have multiple deferes they are executed in reverse
fn Defer() void {
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
    }
    Print("Defer()::x:{d}\n", .{x});
}

//An error set is like an enum (details on Zig's enums later), where each error in the set is a value. There are no exceptions in Zig; errors are values. Let's create an error set.
// COME BACK TO ERRORS
fn Errors() void {
    const FileOpenError = error{
        AccessDenied,
        OutOfMemory,
        FileNotFound,
    };
    const AllocationError = error{OutOfMemory};
    const err: FileOpenError = AllocationError.OutOfMemory;
    Print("Error()::x:{any}\n", .{err});
}

fn Switch() void {
    var x: i8 = 10;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    Print("Switch()::x:{d}\n", .{x});
}

fn increment(value: *u8) void {
    value.* += 1;
}
// Normal pointers in Zig cannot have 0 or null as a value.
// They follow the syntax *T, where T is the child type.
// Referencing is done with &variable, and dereferencing is done with variable.*.
// Zig also has const pointers
fn Pointers() void {
    var x: u8 = 1;
    increment(&x);
    Print("Pointers()::x:{any}\n", .{x});

    // Trying to set a *T to the value 0 is detectable illegal behaviour.
    // const x2: u16 = 0;
    // const y: *u8 = @ptrFromInt(x2);
    // _ = y;

    var x2: u8 = 1;
    const y = &x2;
    y.* += 2;
    Print("Pointers()::X2:{d}, Y Deref:{any}\n", .{ x2, y.* });

    const a: u8 = 0;
    const a_prt = &a;
    // a_ptr,* +=1 NOT ALLOWED BC THIS IS A *COST
    Print("Pointers()::a:{}, typeOf(a_prt):{}\n", .{ a_prt.*, @TypeOf(a_prt) });

    // Multi item pointer
    var array = [_]u8{ 1, 2, 3, 4, 5, 6 };
    var array_prt: [*]u8 = &array;
    Print("Pointers()::array_prt[0]: {}, typeOf(array_prt):{}\n", .{ array_prt[0], @TypeOf(array_prt) });
    array_prt[1] += 1; // 2 +1 = 3 modify the array element
    array_prt += 1; // pointer arithmatic IE: adding 1 byte to the array IE: moving an element up the array so index 0 goes to 1, 1 goes to 2 ect...
    Print("Pointers()::array_prt[0]Inc: {}, typeOf(array_prt):{}\n", .{ array_prt[0], @TypeOf(array_prt) });
    array_prt -= 1; // same as above but you are decamenting
    Print("Pointers()::array_prt[0] Dec: {}, typeOf(array_prt):{}\n", .{ array_prt[0], @TypeOf(array_prt) });
}

fn total(values: []const u8) usize {
    var sum: usize = 0;
    for (values) |v| sum += v;
    return sum;
}

fn Slices() void {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    Print("Slices()::slice:{any}, sliceEnd:{any}, sum:{d}\n", .{ slice, array[1..], total(slice) });
}

fn Enums() void {
    const Direction = enum {
        North,
        South,
        East,
        West,
    };
    // accessing enum values
    Print("Enums()::Direction.North:{}\n", .{@intFromEnum(Direction.North)});

    // Enums can also be given var and const declarations. These act as namespaced globals and their values are unrelated and unattached to instances of the enum type.
    const Mode = enum {
        var count: u32 = 0;
        on,
        off,
    };
    Mode.count += 1;
}

// fn Structs() void {
//     const my_vec = Vec{ .x = 10.0, .y = 11.0, .z = 12.0 };
//     Print("Structs()::struct:{}\n", .{my_vec});
//     my_vec.swap();
//     Print("Structs()::struct after swaps:{}\n", .{my_vec});
// }

// Zig's unions allow you to define types that store one value of many possible typed fields; only one field may be active at one time.
// Bare union types do not have a guaranteed memory layout. Because of this, bare unions cannot be used to reinterpret memory. Accessing a field in a union that is not active is detectable illegal behaviour.
fn Unions() void {
    const res = union {
        int32: i32,
        int64: i64,
        boolean: bool,
    };
    Print("Unions()::res:{any}\n", res);
}

//Blocks in Zig are expressions and can be given labels, which are used to yield values. Here, we are using a label called blk. Blocks yield values, meaning they can be used in place of a value. The value of an empty block {} is a value of the type void.
fn Blocks() void {
    const count = blk: {
        var sum: u32 = 0;
        var i: u32 = 0;
        while (i < 10) : (i += 1) sum += i;
        break :blk sum;
    };
    Print("Blocks()::coun:{d}\n", count);
}

fn LablledLoops() void {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            continue :outer;
        }
    }
}

fn LoopsAsExpressions(begin: i32, end: i32, numToFind: i32) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == numToFind) {
            break true;
        }
    } else false;
}

var numbers_left: i32 = 4;
fn eventually_null() ?i32 {
    if (numbers_left == 0) return null;
    numbers_left -= 1;
    return numbers_left;
}

fn Optionals() !void {
    var found_index: ?usize = null;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 12 };
    for (data, 0..) |v, i| {
        if (v == 10) found_index = i;
    }
    Print("Optionals()::foundIndex:{any}\n", .{found_index});

    // Orelse
    const a: ?f32 = null;
    const fall_back: f32 = 22.0;
    const b = a orelse fall_back;
    Print("Optionals()::orElse:{d}\n", .{b});

    //.? is a shorthand for orelse unreachable. This is used for when you know it is impossible for an optional value to be null, and using this to unwrap a null value is detectable illegal behaviour.
    const a2: ?f32 = 5;
    const b2 = a2 orelse unreachable;
    const c2 = a2.?;
    try expect(b2 == c2);
    try expect(@TypeOf(c2) == f32);

    // Here we use an if optional payload capture; a and b are equivalent here. if (b) |value| captures the value of b (in the cases where b is not null), and makes it available as value. As in the union example, the captured value is immutable, but we can still use a pointer capture to modify the value stored in b.
    const a3: ?i32 = 5;
    if (a3 != null) {
        const value = a3.?;
        _ = value;
    }
    var b3: ?i32 = 5;
    if (b3) |*value| {
        value.* += 1;
    }
    try expect(b3.? == 6);

    var sum2: i32 = 0;
    while (eventually_null()) |value| {
        sum2 += value;
    }
    try expect(sum2 == 6);
}
//Function parameters in Zig can be tagged as being comptime. This means that the value passed to that function parameter must be known at compile time. Let's make a function that returns a type. Notice how this function is PascalCase, as it returns a type.
fn Matrix(comptime T: type, comptime width: comptime_int, comptime height: comptime_int) type {
    return [height][width]T;
}

//We can reflect upon types using the built-in @typeInfo, which takes in a type and returns a tagged union. This tagged union type can be found in std.builtin.Type (info on how to make use of imports and std later).
fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16)
            a + b
        else
            @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

//Payload captures use the syntax |value| and appear in many places, some of which we've seen already. Wherever they appear, they are used to "capture" the value from something.
fn PayloadCapture() !void {
    const captures = struct {
        pub fn optionalIf() !void {
            const maybe_num: ?usize = 10;
            if (maybe_num) |n| {
                try expect(@TypeOf(n) == usize);
                try expect(n == 10);
            } else {
                unreachable;
            }
        }
        pub fn errorUnionIfs() !void {
            const el: error{UnknownEntity}!u32 = 5;
            if (el) |entity| {
                try expect(@TypeOf(entity) == u32);
                try expect(entity == 5);
            } else |err| {
                _ = err catch {};
                unreachable;
            }
        }
        pub fn whileOptionals() !void {
            var i: ?u32 = 10;
            while (i) |num| : (i.? -= 1) {
                // num = 10,9,8,...0
                if (num == 1) {
                    i = null;
                    break;
                }
            }
            try expect(i == null);
        }
    };
    try captures.optionalIf();
    try captures.errorUnionIfs();
    try captures.whileOptionals();
}

pub fn main() !void {
    Print("Hello, {s}!\n", .{"World"});

    const number: i32 = 5;
    const number2: u32 = 300;
    const undef: i32 = undefined; //seen as an any type can only be used if type annotation is provided
    Print(" I32: {d}, U32: {d}, Undefined: {any}\n", .{ number, number2, undef });

    const letters: u8 = 'a';
    const word: []const u8 = "Hello"; // slice
    Print("Leters: {}, Word: {s}\n", .{ letters, word });

    // Arrays
    const a = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
    const b = [_]u8{ 'w', 'o', 'r', 'l', 'd' }; // use _ to infer the size of the array
    Print("ALen: {}, Blen: {}\n", .{ a.len, b.len });

    // IFs
    const is_true = true;
    var count: i32 = 0;
    if (is_true) {
        count += 1;
    } else {
        count += 2;
    }

    // IFs as Expressions
    const is_true_2 = true;
    var count2: i32 = 0;
    count2 += if (is_true_2) 1 else 2;
    Print("If is_true_2: {} Expression: {d}\n", .{ is_true_2, count2 });

    // While Loops
    var int: i8 = 0;
    while (int < 10) {
        int += 2;
    }
    try expect(int == 10);
    try expect(While_With_Continue_Expression() == 55);
    try expect(While_With_Continue() == 4);
    try expect(While_With_Break() == 1);
    For_Loops();
    Defer();
    Errors();
    Switch();
    Pointers();
    Slices();
    Enums();
    // Structs();
    // Blocks();
    LablledLoops();
    try expect(LoopsAsExpressions(0, 10, 3));
    try Optionals();
    try expect(Matrix(f32, comptime 4, 4) == [4][4]f32);
    const x = addSmallInts(u16, 20, 30);
    try expect(@TypeOf(x) == u16);
    try expect(x == 50);
    var int1: i8 = 12;
    try expect(@TypeOf(int1) == i8);
    try expect(int1 == 12);
    int1 += 2;
    try expect(int1 == 14);

    const multiply = struct {
        pub fn call(x1: i32, y: i32) i32 {
            return x1 * y;
        }
    }.call;
    Print("Multiply().call::{}\n", .{multiply(23, 56)});

    const multiply2 = struct {
        pub fn call(x1: i32, y: i32) i32 {
            return x1 * y;
        }
    };
    Print("Multiply()::{}\n", .{multiply2.call(12, 12)});

    var p1 = Point.new(12.0, 14.0);
    const p2 = Point.new(24.0, 28.0);
    std.debug.print("P1.distance()::{d:.1}\n", .{p1.distance(p2)});
    std.debug.print("P1: {any}\n", .{p1});
    incrementX(&p1.x);
    std.debug.print("P1 after increment: {any}\n", .{p1});
    try PayloadCapture();
}
