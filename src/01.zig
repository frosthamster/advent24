const std = @import("std");

pub fn solve(_: std.mem.Allocator) !void {
    const fd = try std.fs.cwd().openFile("inputs/01.input", .{});
    defer fd.close();

    var buf: [32]u8 = undefined;
    while (try fd.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
