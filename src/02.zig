const std = @import("std");

const Input = struct {
    const Self = @This();

    rows: std.ArrayList(std.ArrayList(u32)),

    fn deinit(self: Self) void {
        for (self.rows.items) |row| {
            row.deinit();
        }
        self.rows.deinit();
    }
};

fn parse(alloc: std.mem.Allocator, path: []const u8, input: *Input) !void {
    const fd = try std.fs.cwd().openFile(path, .{});
    defer fd.close();

    var buf: [64]u8 = undefined;
    while (try fd.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var row = std.ArrayList(u32).init(alloc);
        errdefer row.deinit();

        var splitted = std.mem.splitSequence(u8, line, " ");
        while (splitted.next()) |num| {
            try row.append(try std.fmt.parseInt(u32, num, 10));
        }

        try input.rows.append(row);
    }
}

pub fn solve1(alloc: std.mem.Allocator, path: []const u8) !void {
    var input: Input = .{ .rows = std.ArrayList(std.ArrayList(u32)).init(alloc) };
    defer input.deinit();

    try parse(alloc, path, &input);

    var safe: u32 = 0;
    outer: for (input.rows.items) |row| {
        var increasing = true;
        var decreasing = true;
        for (1..row.items.len) |i| {
            const cur = row.items[i];
            const prev = row.items[i - 1];
            if (increasing and (cur <= prev or cur - prev > 3)) {
                increasing = false;
            }
            if (decreasing and (cur >= prev or prev - cur > 3)) {
                decreasing = false;
            }
            if (!(increasing or decreasing)) {
                continue :outer;
            }
        }
        safe += 1;
    }

    std.debug.print("021: {any}\n", .{safe});
}

fn idx(i: usize, removed: i64) ?usize {
    if (i != removed) {
        return i;
    }
    if (i == 0) {
        return null;
    }
    return i - 1;
}

pub fn solve2(alloc: std.mem.Allocator, path: []const u8) !void {
    var input: Input = .{ .rows = std.ArrayList(std.ArrayList(u32)).init(alloc) };
    defer input.deinit();

    try parse(alloc, path, &input);

    var safe: u32 = 0;
    for (input.rows.items) |row| {
        var removed: i64 = -1;
        outer: while (removed < row.items.len) : (removed += 1) {
            var increasing = true;
            var decreasing = true;
            for (1..row.items.len) |i| {
                if (i == removed) {
                    continue;
                }
                const cur = row.items[i];
                const prev = row.items[idx(i - 1, removed) orelse continue];
                if (increasing and (cur <= prev or cur - prev > 3)) {
                    increasing = false;
                }
                if (decreasing and (cur >= prev or prev - cur > 3)) {
                    decreasing = false;
                }
                if (!(increasing or decreasing)) {
                    continue :outer;
                }
            }

            safe += 1;
            break;
        }
    }

    std.debug.print("022: {any}\n", .{safe});
}
