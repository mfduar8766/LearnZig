const std = @import("std");

// Memory Sections or Where are the bytes

// Stored on Global Constant section of memoery IE: Static value known at compile time
const PI: f64 = 3.145;
const greeting = "Hello";

// Stored in the global data section
var count: usize = 0;

fn locals() u8 {
    // Here a && b will not live past this functions stack nor will result
    const a: u8 = 1;
    const b: u8 = 2;
    const result: u8 = a + b;
    // Here a copy of result is returned since its a primative number type
    return result;
}

fn badIdea() *u8 {
    var x: u8 = 1;
    x += 1;
    // invalid pointer once th function returns since x is on the stack and will be destroyed once the function ends dangling pointer
    return &x;
}

fn badIdea2() []u8 {
    const array: [5]u8 = .{ 'H', 'E', 'L', 'L', 'O' };
    // Slice is a pointer to an array which contains the pointer to the array + the length of the array [[*]u8, 5]
    const slice = array[2..];
    // Same as above this is an error bc array will be destroyed once the func retuns and slice will be a dangling pointer
    return slice;
}

fn goodIdea(allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
    const array: [5]u8 = .{ 'H', 'E', 'L', 'L', 'O' };
    // s is a []u8 with length of 5 and a pointer of byte on the heap
    const s = try allocator.alloc(u8, 5);
    std.mem.copyForwards(u8, s, &array);
    // This is OK since s points to bytes allocated on the heap
    return s;
}
