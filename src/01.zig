const std = @import("std");

pub fn solve1(alloc: std.mem.Allocator, path: []const u8) !void {
    var left = std.ArrayList(u32).init(alloc);
    var right = std.ArrayList(u32).init(alloc);
    defer left.deinit();
    defer right.deinit();
    try parse(path, &left, &right);

    std.sort.pdq(u32, left.items, {}, comptime std.sort.asc(u32));
    std.sort.pdq(u32, right.items, {}, comptime std.sort.asc(u32));

    var sum: u32 = 0;
    for (left.items, right.items) |u, v| {
        sum += dist(u, v);
    }
    std.debug.print("011: {any}\n", .{sum});
}

pub fn solve2(alloc: std.mem.Allocator, path: []const u8) !void {
    var left = std.ArrayList(u32).init(alloc);
    var right = std.ArrayList(u32).init(alloc);
    defer left.deinit();
    defer right.deinit();
    try parse(path, &left, &right);

    var counter = std.AutoHashMap(u32, u32).init(alloc);
    defer counter.deinit();
    for (right.items) |v| {
        const res = try counter.getOrPut(v);
        if (res.found_existing) {
            res.value_ptr.* += 1;
        } else {
            res.value_ptr.* = 1;
        }
    }

    var sum: u32 = 0;
    for (left.items) |u| {
        sum += u * (counter.get(u) orelse 0);
    }
    std.debug.print("012: {any}\n", .{sum});
}

fn parse(path: []const u8, left: *std.ArrayList(u32), right: *std.ArrayList(u32)) !void {
    const fd = try std.fs.cwd().openFile(path, .{});
    defer fd.close();

    var buf: [32]u8 = undefined;
    while (try fd.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splitted = std.mem.splitSequence(u8, line, "   ");
        const u = try std.fmt.parseInt(u32, splitted.next().?, 10);
        const v = try std.fmt.parseInt(u32, splitted.next().?, 10);
        try left.append(u);
        try right.append(v);
    }
}

fn dist(u: u32, v: u32) u32 {
    if (u > v) {
        return u - v;
    }
    return v - u;
}
