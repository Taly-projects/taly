const std = @import("std");

pub const TokenKeyword = enum {
    Fn,
    Extern,
    Use,
    Return,

    pub fn isKeyword(data: []const u8) ?TokenKeyword {
        if (std.mem.eql(u8, data, "fn")) {
            return TokenKeyword.Fn;
        } else if (std.mem.eql(u8, data, "extern")) {
            return TokenKeyword.Extern;
        } else if (std.mem.eql(u8, data, "use")) {
            return TokenKeyword.Use;
        } else if (std.mem.eql(u8, data, "return")) {
            return TokenKeyword.Return;
        }

        return null;
    }

    pub fn format(self: *const TokenKeyword, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = fmt;
        _ = options;

        switch (self.*) {
            .Fn => return std.fmt.format(writer, "fn", .{}),
            .Use => return std.fmt.format(writer, "use", .{}),
            .Extern => return std.fmt.format(writer, "extern", .{}),
            .Return => return std.fmt.format(writer, "return", .{}),
        }
    }
};

pub const TokenSymbol = enum {
    LeftParenthesis,
    RightParenthesis,
    Comma,
    RightDoubleArrow,
    Colon,

    pub fn format(self: *const TokenSymbol, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        // _ = fmt;
        _ = options;

        if (std.mem.eql(u8, fmt, "full")) {
            switch (self.*) {
                .LeftParenthesis => return std.fmt.format(writer, "Left Parenthesis `(`", .{}),
                .RightParenthesis => return std.fmt.format(writer, "Right Parenthesis `)`", .{}),
                .Comma => return std.fmt.format(writer, "Comma `,`", .{}),
                .RightDoubleArrow => return std.fmt.format(writer, "Right Double Arrow `=>`", .{}),
                .Colon => return std.fmt.format(writer, "Colon `:`", .{})
            }
        } else {
            switch (self.*) {
                .LeftParenthesis => return std.fmt.format(writer, "(", .{}),
                .RightParenthesis => return std.fmt.format(writer, ")", .{}),
                .Comma => return std.fmt.format(writer, ",", .{}),
                .RightDoubleArrow => return std.fmt.format(writer, "=>", .{}),
                .Colon => return std.fmt.format(writer, ":", .{})
            }
        }
    }
};

pub const TokenConstantTag = enum {
    String,
    Int,
    Float
};

pub const TokenConstant = union(TokenConstantTag) {
    String: []const u8,
    Int: []const u8,
    Float: []const u8,

    pub fn format(self: *const TokenConstant, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;

        if (std.mem.eql(u8, fmt, "full")) {
            switch (self.*) {
                .String => |str| return std.fmt.format(writer, "String(\"{s}\")", .{str}),
                .Int => |num| return std.fmt.format(writer, "Int({s})", .{num}),
                .Float => |num| return std.fmt.format(writer, "Float({s})", .{num}),
            }
        } else {
            switch (self.*) {
                .String => |str| return std.fmt.format(writer, "\"{s}\"", .{str}),
                .Int => |num| return std.fmt.format(writer, "{s}", .{num}),
                .Float => |num| return std.fmt.format(writer, "{s}", .{num}),
            }
        }
    }
};

pub const TokenFormat = enum {
    NewLine,
    Tab,

    pub fn format(self: *const TokenFormat, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = fmt;
        _ = options;

        switch (self.*) {
            .NewLine => try writer.writeAll("Newline"),
            .Tab => try writer.writeAll("Tab"),
        }
    }
};

pub const TokenTag = enum {
    Identifier,
    Keyword,
    Symbol,
    Constant,
    Format
};

pub const Token = union(TokenTag) {
    Identifier: []const u8,
    Keyword: TokenKeyword,
    Symbol: TokenSymbol,
    Constant: TokenConstant,
    Format: TokenFormat,

    pub fn isSymbol(self: *const Token, symbol: TokenSymbol) bool {
        switch (self.*) {
            .Symbol => |sym| return sym == symbol,
            else => return false
        }
    }

    pub fn isKeyword(self: *const Token, keyword: TokenKeyword) bool {
        switch (self.*) {
            .Keyword => |kwd| return keyword == kwd,
            else => return false
        }
    }

    pub fn isFormat(self: *const Token, fmt: TokenFormat) bool {
        switch (self.*) {
            .Format => |fmt2| return fmt == fmt2,
            else => return false
        }
    }

    pub fn format(self: *const Token, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;

        if (std.mem.eql(u8, fmt, "full")) {
            switch (self.*) {
                .Identifier => |id| return std.fmt.format(writer, "Identifier({s})", .{id}),
                .Keyword => |keyword| return std.fmt.format(writer, "Keyword({})", .{keyword}),
                .Symbol => |symbol| return std.fmt.format(writer, "Symbol({full})", .{symbol}),
                .Constant => |constant| return std.fmt.format(writer, "Constant({})", .{constant}),
                .Format => |fmt2| return std.fmt.format(writer, "Format({})", .{fmt2}),
            }
        } else {
            switch (self.*) {
                .Identifier => |id| return std.fmt.format(writer, "{s}", .{id}),
                .Keyword => |keyword| return std.fmt.format(writer, "{}", .{keyword}),
                .Symbol => |symbol| return std.fmt.format(writer, "{}", .{symbol}),
                .Constant => |constant| return std.fmt.format(writer, "{}", .{constant}),
                .Format => |fmt2| return std.fmt.format(writer, "Format({})", .{fmt2}),
            }
        }
    }
};

pub const TokenList = std.ArrayList(Token);

pub const Lexer = struct {
    src: []const u8,
    index: usize,
    
    pub fn init(src: []const u8) Lexer {
        return . {
            .src = src,
            .index = 0
        };
    }

    fn getCurrent(self: *const Lexer) u8 {
        return self.peek(0);
    }

    fn peek(self: *const Lexer, offset: usize) u8 {
        const index = self.index + offset;
        if (index >= self.src.len) {
            return 0;
        } else {
            return self.src[index];
        }
    }

    fn advance(self: *Lexer) void {
        self.index += 1;
    }

    fn makeIdentifier(self: *Lexer, allocator: std.mem.Allocator) Token {
        const start_index = self.index;
        var current = self.getCurrent();
        while (std.ascii.isAlphanumeric(current) or current == '_') {
            self.advance();
            current = self.getCurrent();
        }

        const length = self.index - start_index;
        var array = allocator.alloc(u8, length) catch unreachable;

        self.index = start_index;
        var i: usize = 0;
        while (i < length) {
            array[i] = self.getCurrent();
            self.advance();
            i += 1;
        }

        if (TokenKeyword.isKeyword(array)) |keyword| {
            return Token { 
                .Keyword = keyword
            };
        } else {
            return Token {
                .Identifier = array
            };
        }
    }
    
    fn makeString(self: *Lexer, allocator: std.mem.Allocator) Token {
        self.advance();
        const start_index = self.index;
        var current = self.getCurrent();
        while (current != '"') {
            self.advance();
            current = self.getCurrent();
        }

        const length = self.index - start_index;
        var array = allocator.alloc(u8, length) catch unreachable;

        self.index = start_index;
        var i: usize = 0;
        while (i < length) : (i += 1) {
            array[i] = self.getCurrent();
            self.advance();
        }

        return Token {
            .Constant = .{
                .String = array
            }
        };
    } 

    fn makeNumber(self: *Lexer, allocator: std.mem.Allocator) Token {
        const start_index = self.index;
        var current = self.getCurrent();
        var length: usize = 0;
        var float = false;
        while (std.ascii.isDigit(current) or current == '_' or current == '.') {
            self.advance();
            current = self.getCurrent();
            if (current != '_') length += 1;
            if (current == '.') {
                if (float) break;
                float = true;
            }
        }

        var array = allocator.alloc(u8, length) catch unreachable;

        self.index = start_index;
        var i: usize = 0;
        while (i < length) {
            current = self.getCurrent();
            if (current != '_') {
                array[i] = current;
                i += 1;
            } 
            self.advance();
        }

        if (float) {
            return Token {
                .Constant = . {
                    .Float = array
                }
            };
        } else {
            return Token {
                .Constant = . {
                    .Int = array
                }
            };
        }
    }

    pub fn tokenize(self: *Lexer, allocator: std.mem.Allocator) TokenList {
        var tokens = TokenList.init(allocator);

        var current: u8 = 0;
        while (true) {
            current = self.getCurrent();

            var spaces: u8 = 0;
            while (current == ' ') {
                spaces += 1;
                
                if (spaces == 4) {
                    tokens.append(Token { .Format = .Tab }) catch unreachable; 
                    spaces = 0;   
                }

                self.advance();
                current = self.getCurrent();
            }

            if (std.ascii.isAlphabetic(current)) {
                tokens.append(self.makeIdentifier(allocator)) catch unreachable;
                continue;
            } else if (std.ascii.isDigit(current)) {
                tokens.append(self.makeNumber(allocator)) catch unreachable;
                continue;
            } else {
                switch (current) {
                    '"' => tokens.append(self.makeString(allocator)) catch unreachable,
                    '(' => tokens.append(Token { .Symbol = .LeftParenthesis }) catch unreachable,
                    ')' => tokens.append(Token { .Symbol = .RightParenthesis }) catch unreachable,
                    ',' => tokens.append(Token { .Symbol = .Comma }) catch unreachable,
                    '=' => {
                        const next = self.peek(1);
                        if (next == '>') {
                            self.advance();
                            tokens.append(Token { .Symbol = .RightDoubleArrow }) catch unreachable;
                        } else {
                            @panic("Unimplemented!");
                        }
                    },
                    ':' => tokens.append(Token { .Symbol = .Colon }) catch unreachable,
                    ' ' => {
                        // Ignored
                    },
                    '\n' => tokens.append(Token { .Format = .NewLine}) catch unreachable,
                    '\t' => tokens.append(Token { .Format = .Tab}) catch unreachable,
                    0 => break,
                    else => {
                        std.log.err("Unexpected char '{c}'", .{current});
                        @panic("");
                    }
                }
                self.advance();
            }
        }

        return tokens;
    }
};