const std = @import("std");
const position = @import("position.zig");

pub const TokenKeyword = enum(u8) {
    const KEYWORD_NAME = [_][]const u8 {
        "fn",
        "extern",
        "use",
        "return",
        "var",
        "const",
        "and",
        "or",
        "not",
        "if",
        "then",
        "elif",
        "else",
        "end",
        "while",
        "do",
        "continue",
        "break",
        "match",
        "class",
        "new",
        "type",
        "extend"
    };

    Fn = 0,
    Extern,
    Use,
    Return,
    Var,
    Const,
    And,
    Or,
    Not,
    If,
    Then,
    Elif,
    Else,
    End,
    While,
    Do,
    Continue,
    Break,
    Match,
    Class,
    New,
    Type,
    Extend,

    pub fn isKeyword(data: []const u8) ?TokenKeyword {
        var i: usize = 0;
        for (KEYWORD_NAME) |name| {
            if (std.mem.eql(u8, data, name)) {
                return @intToEnum(TokenKeyword, i);
            }
            i += 1;
        }

        return null;
    }

    pub fn format(self: *const TokenKeyword, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = fmt;
        _ = options;

        return std.fmt.format(writer, "{s}", .{KEYWORD_NAME[@enumToInt(self.*)]});
    }
};

pub const TokenSymbol = enum {
    LeftParenthesis,
    RightParenthesis,
    Comma,
    RightDoubleArrow,
    Colon,
    Equal,
    Plus,
    Dash,
    Star,
    Slash,
    RightAngle,
    RightAngleEqual,
    LeftAngle,
    LeftAngleEqual,
    DoubleEqual,
    ExclamationMarkEqual,
    Dot,
    TripleDot,

    pub fn format(self: *const TokenSymbol, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        // _ = fmt;
        _ = options;

        if (std.mem.eql(u8, fmt, "full")) {
            switch (self.*) {
                .LeftParenthesis => return std.fmt.format(writer, "Left Parenthesis `(`", .{}),
                .RightParenthesis => return std.fmt.format(writer, "Right Parenthesis `)`", .{}),
                .Comma => return std.fmt.format(writer, "Comma `,`", .{}),
                .RightDoubleArrow => return std.fmt.format(writer, "Right Double Arrow `=>`", .{}),
                .Colon => return std.fmt.format(writer, "Colon `:`", .{}),
                .Equal => return std.fmt.format(writer, "Equal `=`", .{}),
                .Plus => return std.fmt.format(writer, "Plus `+`", .{}),
                .Dash => return std.fmt.format(writer, "Dash `-`", .{}),
                .Star => return std.fmt.format(writer, "Star `*`", .{}),
                .Slash => return std.fmt.format(writer, "Slash `/`", .{}),
                .RightAngle => return std.fmt.format(writer, "Right Angle `>`", .{}),
                .RightAngleEqual => return std.fmt.format(writer, "Right Angle Equal `>=`", .{}),
                .LeftAngle => return std.fmt.format(writer, "Left Angle `<`", .{}),
                .LeftAngleEqual => return std.fmt.format(writer, "Left Angle Equal `<=`", .{}),
                .DoubleEqual => return std.fmt.format(writer, "Double Equal `==`", .{}),
                .ExclamationMarkEqual => return std.fmt.format(writer, "Exclamation Mark Equal `!=`", .{}),
                .Dot => return std.fmt.format(writer, "Dot `.`", .{}),
                .TripleDot => return std.fmt.format(writer, "Triple Dot `...`", .{}),
            }
        } else {
            switch (self.*) {
                .LeftParenthesis => return std.fmt.format(writer, "(", .{}),
                .RightParenthesis => return std.fmt.format(writer, ")", .{}),
                .Comma => return std.fmt.format(writer, ",", .{}),
                .RightDoubleArrow => return std.fmt.format(writer, "=>", .{}),
                .Colon => return std.fmt.format(writer, ":", .{}),
                .Equal => return std.fmt.format(writer, "=", .{}),
                .Plus => return std.fmt.format(writer, "+", .{}),
                .Dash => return std.fmt.format(writer, "-", .{}),
                .Star => return std.fmt.format(writer, "*", .{}),
                .Slash => return std.fmt.format(writer, "/", .{}),
                .RightAngle => return std.fmt.format(writer, ">", .{}),
                .RightAngleEqual => return std.fmt.format(writer, ">=", .{}),
                .LeftAngle => return std.fmt.format(writer, "<", .{}),
                .LeftAngleEqual => return std.fmt.format(writer, "<=", .{}),
                .DoubleEqual => return std.fmt.format(writer, "==", .{}),
                .ExclamationMarkEqual => return std.fmt.format(writer, "!=", .{}),
                .Dot => return std.fmt.format(writer, ".", .{}),
                .TripleDot => return std.fmt.format(writer, "...", .{}),
            }
        }
    }
};

pub const TokenConstantTag = enum {
    String,
    Int,
    Float,
    Bool,
};

pub const TokenConstant = union(TokenConstantTag) {
    String: []const u8,
    Int: []const u8,
    Float: []const u8,
    Bool: bool,

    pub fn format(self: *const TokenConstant, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;

        if (std.mem.eql(u8, fmt, "full")) {
            switch (self.*) {
                .String => |str| return std.fmt.format(writer, "String(\"{s}\")", .{str}),
                .Int => |num| return std.fmt.format(writer, "Int({s})", .{num}),
                .Float => |num| return std.fmt.format(writer, "Float({s})", .{num}),
                .Bool => |b| return std.fmt.format(writer, "Bool({})", .{b}),
            }
        } else {
            switch (self.*) {
                .String => |str| return std.fmt.format(writer, "\"{s}\"", .{str}),
                .Int => |num| return std.fmt.format(writer, "{s}", .{num}),
                .Float => |num| return std.fmt.format(writer, "{s}", .{num}),
                .Bool => |b| return std.fmt.format(writer, "{}", .{b}),
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
    Format,
    Label,
};

pub const Token = union(TokenTag) {
    Identifier: []const u8,
    Keyword: TokenKeyword,
    Symbol: TokenSymbol,
    Constant: TokenConstant,
    Format: TokenFormat,
    Label: []const u8,

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
                .Label => |id| return std.fmt.format(writer, "Label({s})", .{id}),
            }
        } else {
            switch (self.*) {
                .Identifier => |id| return std.fmt.format(writer, "{s}", .{id}),
                .Keyword => |keyword| return std.fmt.format(writer, "{}", .{keyword}),
                .Symbol => |symbol| return std.fmt.format(writer, "{}", .{symbol}),
                .Constant => |constant| return std.fmt.format(writer, "{}", .{constant}),
                .Format => |fmt2| return std.fmt.format(writer, "{}", .{fmt2}),
                .Label => |id| return std.fmt.format(writer, "${s}", .{id}),
            }
        }
    }
};

pub const PositionedToken = position.Positioned(Token);
pub const TokenList = std.ArrayList(PositionedToken);

pub const Lexer = struct {
    file_name: []const u8,
    src: []const u8,
    pos: position.Position,
    
    pub fn init(file_name: []const u8, src: []const u8) Lexer {
        return . {
            .file_name = file_name,
            .src = src,
            .pos = .{}
        };
    }

    fn getCurrent(self: *const Lexer) u8 {
        return self.peek(0);
    }

    fn peek(self: *const Lexer, offset: usize) u8 {
        const index = self.pos.index + offset;
        if (index >= self.src.len) {
            return 0;
        } else {
            return self.src[index];
        }
    }

    fn advance(self: *Lexer) void {
        self.pos.advance(self.getCurrent());
    }

    fn makeSingle(self: *Lexer, token: Token) PositionedToken {
        const start = self.pos;
        var end = self.pos;
        end.advance(self.getCurrent());
        return PositionedToken.init(token, start, end);
    }

    fn makeIdentifier(self: *Lexer, allocator: std.mem.Allocator) PositionedToken {
        const start_pos = self.pos;
        var current = self.getCurrent();
        while (std.ascii.isAlphanumeric(current) or current == '_') {
            self.advance();
            current = self.getCurrent();
        }
        const end_pos = self.pos;

        const length = self.pos.index - start_pos.index;
        var array = allocator.alloc(u8, length) catch unreachable;

        self.pos = start_pos;
        var i: usize = 0;
        while (i < length) {
            array[i] = self.getCurrent();
            self.advance();
            i += 1;
        }

        if (TokenKeyword.isKeyword(array)) |keyword| {
            return PositionedToken.init( Token { 
                .Keyword = keyword
            }, start_pos, end_pos);
        } else if (std.mem.eql(u8, array, "true")) {
            return PositionedToken.init( Token {
                .Constant = .{
                    .Bool = true
                }
            }, start_pos, end_pos);
        } else if (std.mem.eql(u8, array, "false")) {
            return PositionedToken.init(Token {
                .Constant = .{
                    .Bool = false
                }
            }, start_pos, end_pos);
        } else {
            return PositionedToken.init(Token {
                .Identifier = array
            }, start_pos, end_pos);
        }
    }
    
    fn makeString(self: *Lexer, allocator: std.mem.Allocator) PositionedToken {
        const start = self.pos;
        self.advance();
        const start_pos = self.pos;
        var current = self.getCurrent();
        while (current != '"') {
            self.advance();
            current = self.getCurrent();
        }
        const length = self.pos.index - start_pos.index;
        var array = allocator.alloc(u8, length) catch unreachable;

        self.advance();
        const end = self.pos;

        self.pos = start_pos;
        var i: usize = 0;
        while (i < length) : (i += 1) {
            array[i] = self.getCurrent();
            self.advance();
        }

        return PositionedToken.init(Token {
            .Constant = .{
                .String = array
            }
        }, start, end);
    } 

    fn makeNumber(self: *Lexer, allocator: std.mem.Allocator) PositionedToken {
        const start_pos = self.pos;
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
        const end_pos = self.pos;

        var array = allocator.alloc(u8, length) catch unreachable;

        self.pos = start_pos;
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
            return PositionedToken.init(Token {
                .Constant = . {
                    .Float = array
                }
            }, start_pos, end_pos);
        } else {
            return PositionedToken.init(Token {
                .Constant = . {
                    .Int = array
                }
            }, start_pos, end_pos);
        }
    }

    fn makeLabel(self: *Lexer, allocator: std.mem.Allocator) PositionedToken {
        const start = self.pos;
        self.advance();
        const start_pos = self.pos;
        var current = self.getCurrent();
        while (std.ascii.isAlphanumeric(current) or current == '_') {
            self.advance();
            current = self.getCurrent();
        }
        const end_pos = self.pos;

        const length = self.pos.index - start_pos.index;
        var array = allocator.alloc(u8, length) catch unreachable;

        self.pos = start_pos;
        var i: usize = 0;
        while (i < length) {
            array[i] = self.getCurrent();
            self.advance();
            i += 1;
        }

        return PositionedToken.init(Token {
            .Label = array
        }, start, end_pos);
    }

    pub fn tokenize(self: *Lexer, allocator: std.mem.Allocator) TokenList {
        var tokens = TokenList.init(allocator);

        var current: u8 = 0;
        while (true) {
            current = self.getCurrent();

            var spaces: u8 = 0;
            var start_pos = self.pos;
            while (current == ' ') {
                spaces += 1;
                
                if (spaces == 4) {
                    var end_pos = self.pos;
                    end_pos.advance(' ');
                    tokens.append(PositionedToken.init(Token { .Format = .Tab }, start_pos, end_pos)) catch unreachable; 
                    start_pos = end_pos;
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
                    '$' => {
                        tokens.append(self.makeLabel(allocator)) catch unreachable;
                        continue;
                    },
                    '(' => tokens.append(self.makeSingle(Token { .Symbol = .LeftParenthesis })) catch unreachable,
                    ')' => tokens.append(self.makeSingle(Token { .Symbol = .RightParenthesis })) catch unreachable,
                    ',' => tokens.append(self.makeSingle(Token { .Symbol = .Comma })) catch unreachable,
                    '=' => {
                        const next = self.peek(1);
                        if (next == '>') {
                            start_pos = self.pos;
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('>');
                            tokens.append(PositionedToken.init(Token { .Symbol = .RightDoubleArrow }, start_pos, end_pos)) catch unreachable;
                        } else if (next == '=') {
                            start_pos = self.pos;
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('=');
                            tokens.append(PositionedToken.init(Token { .Symbol = .DoubleEqual }, start_pos, end_pos)) catch unreachable;
                        } else {
                            tokens.append(self.makeSingle(Token { .Symbol = .Equal })) catch unreachable;
                        }
                    },
                    '>' => {
                        const next = self.peek(1);
                        if (next == '=') {
                            start_pos = self.pos;
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('=');
                            tokens.append(PositionedToken.init(Token { .Symbol = .RightAngleEqual }, start_pos, end_pos)) catch unreachable;
                        } else {
                            tokens.append(self.makeSingle(Token { .Symbol = .RightAngle })) catch unreachable;
                        }
                    },
                    '<' => {
                        const next = self.peek(1);
                        if (next == '=') {
                            start_pos = self.pos;
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('=');
                            tokens.append(PositionedToken.init(Token { .Symbol = .LeftAngleEqual }, start_pos, end_pos)) catch unreachable;
                        } else {
                            tokens.append(self.makeSingle(Token { .Symbol = .LeftAngle })) catch unreachable;
                        }
                    },
                    '!' => {
                        const next = self.peek(1);
                        if (next == '=') {
                            start_pos = self.pos;
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('=');
                            tokens.append(PositionedToken.init(Token { .Symbol = .ExclamationMarkEqual }, start_pos, end_pos)) catch unreachable;
                        } else {
                            const positioned = self.makeSingle(Token { .Format = .NewLine });
                            positioned.errorMessage("Unexpected char '{c}':", .{current}, self.src, self.file_name);
                        }
                    },
                    ':' => tokens.append(self.makeSingle(Token { .Symbol = .Colon })) catch unreachable,
                    '+' => tokens.append(self.makeSingle(Token { .Symbol = .Plus })) catch unreachable,
                    '-' => tokens.append(self.makeSingle(Token { .Symbol = .Dash })) catch unreachable,
                    '*' => tokens.append(self.makeSingle(Token { .Symbol = .Star })) catch unreachable,
                    '/' => tokens.append(self.makeSingle(Token { .Symbol = .Slash })) catch unreachable,
                    '.' => {
                        const next = self.peek(1);
                        const next2 = self.peek(2);
                        if (next == '.' and next2 == '.') {
                            start_pos = self.pos;
                            self.advance();
                            self.advance();
                            var end_pos = self.pos;
                            end_pos.advance('.');
                            tokens.append(PositionedToken.init(Token { .Symbol = .TripleDot }, start_pos, end_pos)) catch unreachable;
                        } else {
                            tokens.append(self.makeSingle(Token { .Symbol = .Dot })) catch unreachable;
                        }
                    },
                    ' ', '\r' => {
                        // Ignored
                    },
                    '\n' => tokens.append(self.makeSingle(Token { .Format = .NewLine})) catch unreachable,
                    '\t' => tokens.append(self.makeSingle(Token { .Format = .Tab})) catch unreachable,
                    '#' => {
                        self.advance();
                        current = self.getCurrent();
                        while (current != '\n' and current != 0) {
                            self.advance();
                            current = self.getCurrent();
                        }
                    },
                    0 => break,
                    else => {
                        const positioned = self.makeSingle(Token { .Format = .NewLine });
                        positioned.errorMessage("Unexpected char '{c}':", .{current}, self.src, self.file_name);
                    }
                }
                self.advance();
            }
        }

        return tokens;
    }
};