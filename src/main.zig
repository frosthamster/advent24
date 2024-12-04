const std = @import("std");
const d01 = @import("01.zig");
const d02 = @import("02.zig");
const d03 = @import("03.zig");
const d04 = @import("04.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) @panic("leak");
    }

    var args_it = try std.process.argsWithAllocator(alloc);
    defer args_it.deinit();

    var args = std.ArrayList([]const u8).init(alloc);
    defer args.deinit();

    _ = args_it.skip();
    while (args_it.next()) |arg| {
        try args.append(arg);
    }

    const debug = args.items.len > 1 and std.mem.eql(u8, args.items[1], "--debug");
    if (std.mem.eql(u8, args.items[0], "011")) {
        try d01.solve1(alloc, path(debug, "inputs/01.input"));
    }
    if (std.mem.eql(u8, args.items[0], "012")) {
        try d01.solve2(alloc, path(debug, "inputs/01.input"));
    }
    if (std.mem.eql(u8, args.items[0], "021")) {
        try d02.solve1(alloc, path(debug, "inputs/02.input"));
    }
    if (std.mem.eql(u8, args.items[0], "022")) {
        try d02.solve2(alloc, path(debug, "inputs/02.input"));
    }
    if (std.mem.eql(u8, args.items[0], "031")) {
        try d03.solve1(alloc, path(debug, "inputs/03.input"));
    }
    if (std.mem.eql(u8, args.items[0], "032")) {
        try d03.solve2(alloc, path(debug, "inputs/03.input"));
    }
    if (std.mem.eql(u8, args.items[0], "041")) {
        try d04.solve1(alloc, path(debug, "inputs/04.input"));
    }
    if (std.mem.eql(u8, args.items[0], "042")) {
        try d04.solve2(alloc, path(debug, "inputs/04.input"));
    }
}

fn path(debug: bool, p: []const u8) []const u8 {
    if (debug) {
        return "inputs/debug.input";
    }
    return p;
}
