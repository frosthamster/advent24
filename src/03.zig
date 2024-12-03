const std = @import("std");

const State = enum {
    nil,
    m,
    u,
    l,
    mul_open_br,
    l_int,
    comma,
    r_int,

    d,
    o,
    do_open_br,

    n,
    apostr,
    t,
    dont_open_br,
};

fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

// mul(44,46)
// do()
// don't()
const MulParser = struct {
    parseDos: bool,

    state: State = .nil,
    enabled: bool = true,
    l: u32 = 0,
    r: u32 = 0,

    const Self = @This();

    fn reFeed(self: *Self, next: u8) ?u64 {
        self.state = .nil;
        return self.feed(next);
    }

    fn feed(self: *Self, next: u8) ?u64 {
        switch (self.state) {
            .nil => switch (next) {
                'm' => self.state = .m,
                'd' => self.state = .d,
                else => {},
            },

            .d => {
                if (next != 'o') return self.reFeed(next);
                self.state = .o;
            },
            .o => switch (next) {
                '(' => self.state = .do_open_br,
                'n' => self.state = .n,
                else => return self.reFeed(next),
            },
            .do_open_br => {
                self.state = .nil;
                if (next != ')') return self.feed(next);
                self.enabled = true;
            },

            .n => {
                if (next != '\'') return self.reFeed(next);
                self.state = .apostr;
            },
            .apostr => {
                if (next != 't') return self.reFeed(next);
                self.state = .t;
            },
            .t => {
                if (next != '(') return self.reFeed(next);
                self.state = .dont_open_br;
            },
            .dont_open_br => {
                self.state = .nil;
                if (next != ')') return self.feed(next);
                self.enabled = false;
            },

            .m => {
                if (next != 'u') return self.reFeed(next);
                self.state = .u;
            },
            .u => {
                if (next != 'l') return self.reFeed(next);
                self.state = .l;
            },
            .l => {
                if (next != '(') return self.reFeed(next);
                self.state = .mul_open_br;
            },
            .mul_open_br => {
                if (!isDigit(next)) return self.reFeed(next);
                self.state = .l_int;
                self.l = std.fmt.charToDigit(next, 10) catch unreachable;
            },
            .l_int => {
                if (isDigit(next)) {
                    self.l = self.l * 10 + (std.fmt.charToDigit(next, 10) catch unreachable);
                } else if (next == ',') {
                    self.state = .comma;
                } else return self.reFeed(next);
            },
            .comma => {
                if (!isDigit(next)) return self.reFeed(next);
                self.state = .r_int;
                self.r = std.fmt.charToDigit(next, 10) catch unreachable;
            },
            .r_int => {
                if (isDigit(next)) {
                    self.r = self.r * 10 + (std.fmt.charToDigit(next, 10) catch unreachable);
                } else if (next == ')') {
                    self.state = .nil;
                    if (!self.parseDos or self.enabled) {
                        return self.l * self.r;
                    }
                } else return self.reFeed(next);
            },
        }

        return null;
    }
};

fn solve(path: []const u8, comptime parseDos: bool) !u64 {
    const fd = try std.fs.cwd().openFile(path, .{});
    defer fd.close();

    var r = std.io.bufferedReader(fd.reader());
    var reader = r.reader();
    var sum: u64 = 0;
    var parser = MulParser{ .parseDos = parseDos };
    var buf: [1]u8 = undefined;
    while (try reader.read(&buf) != 0) {
        if (parser.feed(buf[0])) |mul| {
            sum += mul;
        }
    }

    return sum;
}

pub fn solve1(_: std.mem.Allocator, path: []const u8) !void {
    const sum = try solve(path, false);
    std.debug.print("031: {any}\n", .{sum});
}

pub fn solve2(_: std.mem.Allocator, path: []const u8) !void {
    const sum = try solve(path, true);
    std.debug.print("032: {any}\n", .{sum});
}
