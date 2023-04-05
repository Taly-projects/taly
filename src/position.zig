const std = @import("std");

var SHOULD_PANIC: bool = true;

pub const Position = struct {
    index: usize = 0,
    column: usize = 0,
    column_index: usize = 0,
    line: usize = 0,

    pub fn advance(self: *Position, chr: u8) void {
        self.index += 1;
        if (chr == '\n') {
            self.line += 1;
            self.column = 0;
            self.column_index = 0;
        } else if (chr == '\t') {
            self.column += 4;
            self.column_index += 1;
        } else {
            self.column += 1;
            self.column_index += 1;
        }
    }

    pub fn format(self: *const Position, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try std.fmt.format(writer, "{d}:{d}", .{self.line + 1, self.column_index + 1});
    }
};

pub fn Positioned(comptime T: type) type {
    return struct {
        const Self = @This();
        
        start: Position,
        end: Position,
        data: T,

        pub fn init(data: T, start: Position, end: Position) Self {
            return . {
                .start = start,
                .end = end,
                .data = data
            };
        }

        pub fn printMessage(self: *const Self, writer: anytype, src: []const u8) !void {
            var lines = std.mem.split(u8, src, "\n");

            // Go to the start line
            var i: usize = 0;
            while (i < self.start.line) : (i += 1) {
                _ = lines.next();
            }

            // Loop through all the lines
            i = self.start.line;
            while (i <= self.end.line) : (i += 1) {
                const line = lines.next() orelse break;

                // Compute offset and error length
                const offset = if (i == self.start.line) self.start.column else 0;
                const length = if (i == self.end.line) self.end.column else line.len;

                // Write line
                try std.fmt.format(writer, "\x1b[38;2;81;81;255m{d: >6} | \x1b[0m", .{i + 1});
                try std.fmt.format(writer, "{s}\n", .{line});

                // Write offset
                try writer.writeAll("         ");
                var j: usize = 0;
                while (j < offset) : (j += 1) try writer.writeAll(" ");
                while (j < length) : (j += 1) try writer.writeAll("^");
                try writer.writeAll("\n");
            }
        }  

        pub fn errorMessage(self: *const Self, comptime msg: []const u8, args: anytype, src: []const u8, file_name: []const u8) noreturn {
            const stdout = std.io.getStdOut();
            
            std.fmt.format(stdout.writer(), "\x1b[1m\x1b[38;2;255;81;81m{s}:{}:\x1b[0m ", .{file_name, self.start}) catch unreachable;
            std.fmt.format(stdout.writer(), msg, args) catch unreachable;
            stdout.writeAll("\n") catch unreachable;

            self.printMessage(stdout.writer(), src) catch unreachable;

            if (SHOULD_PANIC) @panic("")
            else std.os.exit(0);
        }

        pub fn errorMessageReturn(self: *const Self, comptime msg: []const u8, args: anytype, src: []const u8, file_name: []const u8) void {
            const stdout = std.io.getStdOut();
            
            std.fmt.format(stdout.writer(), "\x1b[1m\x1b[38;2;255;81;81m{s}:{}:\x1b[0m ", .{file_name, self.start}) catch unreachable;
            std.fmt.format(stdout.writer(), msg, args) catch unreachable;
            stdout.writeAll("\n") catch unreachable;

            self.printMessage(stdout.writer(), src) catch unreachable;
        }
    };
}

pub fn errorMessage(comptime msg: []const u8, args: anytype, file_name: []const u8) noreturn {
    const stdout = std.io.getStdOut();
    
    std.fmt.format(stdout.writer(), "\x1b[1m\x1b[38;2;255;81;81m{s}:\x1b[0m ", .{file_name}) catch unreachable;
    std.fmt.format(stdout.writer(), msg, args) catch unreachable;
    stdout.writeAll("\n") catch unreachable;

    if (SHOULD_PANIC) @panic("")
    else std.os.exit(0);
}
