const std = @import("std");

const Input = struct {
    rows: std.ArrayList(std.ArrayList(u8)),

    const Self = @This();

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

    var buf: [256]u8 = undefined;
    while (try fd.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var row = try std.ArrayList(u8).initCapacity(alloc, line.len);
        errdefer row.deinit();
        try row.appendSlice(line);
        try input.rows.append(row);
    }
}

const WordFinder = struct {
    input: *const Input,
    word: []const u8,

    const Self = @This();

    fn find(self: *Self, i: i64, j: i64, di: i8, dj: i8, wi: usize) u32 {
        if (wi >= self.word.len) return 1;
        if (i < 0 or i >= self.input.rows.items.len or j < 0 or j >= self.input.rows.items[0].items.len) return 0;
        if (self.input.rows.items[@intCast(i)].items[@intCast(j)] != self.word[wi]) return 0;
        return self.find(i + di, j + dj, di, dj, wi + 1);
    }
};

pub fn solve1(alloc: std.mem.Allocator, path: []const u8) !void {
    var input: Input = .{ .rows = std.ArrayList(std.ArrayList(u8)).init(alloc) };
    defer input.deinit();

    try parse(alloc, path, &input);

    var count: u32 = 0;
    var f = WordFinder{ .input = &input, .word = "XMAS" };
    for (input.rows.items, 0..) |row, i| {
        for (0..row.items.len) |j| {
            const ii: i64 = @intCast(i);
            const jj: i64 = @intCast(j);
            count += f.find(ii, jj, 1, 0, 0) +
                f.find(ii, jj, -1, 0, 0) +
                f.find(ii, jj, 0, 1, 0) +
                f.find(ii, jj, 0, -1, 0) +
                f.find(ii, jj, 1, 1, 0) +
                f.find(ii, jj, -1, -1, 0) +
                f.find(ii, jj, -1, 1, 0) +
                f.find(ii, jj, 1, -1, 0);
        }
    }

    std.debug.print("041: {any}\n", .{count});
}

pub fn solve2(alloc: std.mem.Allocator, path: []const u8) !void {
    var input: Input = .{ .rows = std.ArrayList(std.ArrayList(u8)).init(alloc) };
    defer input.deinit();

    try parse(alloc, path, &input);

    var count: u32 = 0;
    var f = WordFinder{ .input = &input, .word = "MAS" };
    for (0..input.rows.items.len - 2) |i| {
        for (0..input.rows.items[0].items.len - 2) |j| {
            const ii: i64 = @intCast(i);
            const jj: i64 = @intCast(j);
            const c = f.find(ii, jj + 2, 1, -1, 0) + f.find(ii + 2, jj, -1, 1, 0) +
                f.find(ii + 2, jj + 2, -1, -1, 0) + f.find(ii, jj, 1, 1, 0);

            if (c == 2) count += 1;
        }
    }

    std.debug.print("042: {any}\n", .{count});
}
