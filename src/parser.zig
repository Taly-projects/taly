const std = @import("std");
const lexer = @import("lexer.zig");

pub const ValueNodeTag = enum {
    String
};

pub const ValueNode = union(ValueNodeTag) {
    String: []const u8,

    pub fn writeXML(self: *const ValueNode, writer: anytype, tabs: usize) anyerror!void {
        switch (self.*) {
            .String => |str| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<string>{s}</string>\n", .{str});
            }
        }
    }

};

pub const FunctionDefinitionParameter = struct {
    name: []const u8,
    data_type: []const u8,

    pub fn writeXML(self: *const FunctionDefinitionParameter, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<parameter>\n");

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<type>{s}</type>\n", .{self.data_type});

        // Add tabs
        i = 0;        
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</parameter>");
    }
    
};

pub const FunctionDefinitionParameters = std.ArrayList(FunctionDefinitionParameter);

pub const FunctionDefinitionNode = struct {
    name: []const u8,
    parameters: FunctionDefinitionParameters,
    return_type: ?[]const u8,
    external: bool,
    body: NodeList,

    pub fn writeXML(self: *const FunctionDefinitionNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<function-def>\n");

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<parameters>");
        i = 0;
        for (self.parameters.items) |param| {
            try writer.writeAll("\n");
            try param.writeXML(writer, tabs + 2);
        }
        if (self.parameters.items.len > 0) {
            try writer.writeAll("\n");
            
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</parameters>\n");
            
        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<type>{?s}</type>\n", .{self.return_type});
            
        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<external>{}</external>\n", .{self.external});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<body>");
        i = 0;
        for (self.body.items) |node| {
            if (i == 0) try writer.writeAll("\n");
            try node.writeXML(writer, tabs + 2);
            i += 1;
        }
        if (self.body.items.len > 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</body>\n");

        // Add tabs
        i = 0;        
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</function-def>\n");
    }
    
};

pub const FunctionCallNode = struct {
    name: []const u8,
    parameters: NodeList,

    pub fn writeXML(self: *const FunctionCallNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<function-call>\n");

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<parameters>");
        i = 0;
        for (self.parameters.items) |param| {
            if (i == 0) try writer.writeAll("\n");
            try param.writeXML(writer, tabs + 2);
            i += 1;
        }
        if (self.parameters.items.len > 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</parameters>\n");

        // Add tabs
        i = 0;        
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</function-call>\n");
    }
};

pub const UseNode = struct {
    path: []const u8,

    pub fn writeXML(self: *const UseNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<use>\n");

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        try std.fmt.format(writer, "<path>{s}</path>", .{self.path});

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</use>\n");
    }
};

pub const NodeTag = enum {
    Value,
    FunctionDefinition,
    FunctionCall,
    Use,
};

pub const Node = union(NodeTag) {
    Value: ValueNode,
    FunctionDefinition: FunctionDefinitionNode,
    FunctionCall: FunctionCallNode,
    Use: UseNode,

    pub fn writeXML(self: *const Node, writer: anytype, tabs: usize) anyerror!void {
        switch (self.*) {
            .Value => |node| return node.writeXML(writer, tabs),
            .FunctionDefinition => |node| return node.writeXML(writer, tabs),
            .FunctionCall => |node| return node.writeXML(writer, tabs),
            .Use => |node| return node.writeXML(writer, tabs),
        }
    }

    pub fn format(self: *const Node, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;
        _ = fmt;

        switch (self.*) {
            .Value => |node| node.writeXML(writer, 0) catch unreachable,
            .FunctionDefinition => |node| node.writeXML(writer, 0) catch unreachable,
            .FunctionCall => |node| node.writeXML(writer, 0) catch unreachable,
            .Use => |node| node.writeXML(writer, 0) catch unreachable,
        }
    }
};

pub const NodeList = std.ArrayList(Node);

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: lexer.TokenList,
    index: usize = 0,
    tabs: usize = 0,

    pub fn init(tokens: lexer.TokenList, allocator: std.mem.Allocator) Parser {
        return . {
            .allocator = allocator,
            .tokens = tokens,
        };
    }

    fn getCurrent(self: *const Parser) ?lexer.Token {
        if (self.index >= self.tokens.items.len) return null;
        return self.tokens.items[self.index];
    }

    fn expectCurrent(self: *const Parser) lexer.Token {
        if (self.getCurrent()) |token| {
            return token;
        } else {
            std.log.err("Unexpected EOF {}!", .{self.index});
            @panic("");
        }
    }

    fn expectIdentifier(self: *const Parser) []const u8 {
        switch (self.expectCurrent()) {
            .Identifier => |id| return id,
            else => {
                std.log.err("Unexpected EOF!", .{});
                @panic("");
            }
        }
    }

    fn expectExactKeyword(self: *const Parser, keyword: lexer.TokenKeyword) void {
        if (!self.expectCurrent().isKeyword(keyword)) {
            std.log.err("Unexpected Token, should be '{}'!", .{keyword});
            @panic("");
        }
    }

    fn expectSymbol(self: *const Parser, symbol: lexer.TokenSymbol) void {
        switch (self.expectCurrent()) {
            .Symbol => |sym| {
                if (sym != symbol) {
                    std.log.err("Unexpected EOF!", .{});
                    @panic("");
                } 
            },
            else => {
                std.log.err("Unexpected EOF!", .{});
                @panic("");
            }
        }
    }

    fn expectString(self: *const Parser) []const u8 {
        switch (self.expectCurrent()) {
            .Constant => |constant| {
                switch (constant) {
                    .String => |str| return str,
                }
            },
            else => {
                std.log.err("Unexpected Token!", .{});
                @panic("");
            }
        }
    }

    fn advance(self: *Parser) void {
        self.index += 1;
    }

    fn parseFunctionDefinition(self: *Parser, external: bool) Node {
        self.advance();
        const id = self.expectIdentifier();
        self.advance();

        self.expectSymbol(lexer.TokenSymbol.LeftParenthesis);
        self.advance();
        var parameters = FunctionDefinitionParameters.init(self.allocator);
        var current = self.expectCurrent();
        while (!current.isSymbol(lexer.TokenSymbol.RightParenthesis)) {
            if (parameters.items.len != 0) {
                self.expectSymbol(lexer.TokenSymbol.Comma);
                self.advance();
            }
            const param_name = self.expectIdentifier();
            self.advance();
            self.expectSymbol(lexer.TokenSymbol.Colon);
            self.advance();
            const param_type = self.expectIdentifier();
            self.advance();
            parameters.append(FunctionDefinitionParameter {
                .name = param_name,
                .data_type = param_type
            }) catch unreachable;
            current = self.expectCurrent();
        }
        self.advance();

        var return_type: ?[]const u8 = null;
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            switch (current) {
                .Symbol => |symbol| {
                    if (symbol == lexer.TokenSymbol.Colon) {
                        self.advance();
                        return_type = self.expectIdentifier();
                        self.advance();
                    }
                },
                else => {}
            }
        }
        
        var body = NodeList.init(self.allocator);
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            if (current.isSymbol(lexer.TokenSymbol.RightDoubleArrow)) {
                self.advance();
                self.tabs += 1;
                var tab_count: usize = 0;
                var first = true;
                while (self.getCurrent() != null) {
                    current = self.getCurrent().?;
                    if (current.isFormat(lexer.TokenFormat.Tab)) {
                        tab_count += 1;
                        self.advance();
                    } if (current.isFormat(lexer.TokenFormat.NewLine)) {
                        tab_count = 0;
                        first = false;
                        self.advance();
                    } else if (first or tab_count >= self.tabs) {
                        const node = self.parseCurrent();
                        body.append(node) catch unreachable;
                    } else {
                        break;
                    }
                }
                self.tabs -= 1;
            }
        }

        return . {
            .FunctionDefinition = . {
                .name = id,
                .parameters = parameters,
                .return_type = return_type,
                .external = external,
                .body = body
            }
        };
    }

    fn parseExpr(self: *Parser) Node {
        const current = self.expectCurrent();
        switch (current) {
            .Constant => |constant| return self.handleConstant(constant),
            else => {
                std.log.err("Unexpected Token, should be expr!", .{});
                @panic("");
            }
        }
        self.parseExpr();
    }
    
    fn handleConstant(self: *Parser, value: lexer.TokenConstant) Node {
        switch (value) {
            .String => |str| {
                self.advance();
                return Node {
                    .Value = . {
                        .String = str
                    }
                };
            }
        }
    }

    fn handleIdentifier(self: *Parser, id: []const u8) Node {
        self.advance();
        self.expectSymbol(lexer.TokenSymbol.LeftParenthesis);
        self.advance();
        var parameters = NodeList.init(self.allocator);
        var current = self.expectCurrent();
        while (!current.isSymbol(lexer.TokenSymbol.RightParenthesis)) {
            if (parameters.items.len != 0) {
                self.expectSymbol(lexer.TokenSymbol.Comma);
                self.advance();
            }
            const expr = self.parseExpr();
            parameters.append(expr) catch unreachable;
            current = self.expectCurrent();
        }
        self.advance();
        
        return Node {
            .FunctionCall = .{
                .name = id,
                .parameters = parameters
            }
        };
    }

    fn parseUse(self: *Parser) Node {
        self.advance();
        const path = self.expectString();
        self.advance();

        return Node {
            .Use = .{
                .path = path
            }
        };
    }

    fn handleKeyword(self: *Parser, keyword: lexer.TokenKeyword) Node {
        switch (keyword) {
            .Fn => return self.parseFunctionDefinition(false),
            .Extern => {
                self.advance();
                self.expectExactKeyword(lexer.TokenKeyword.Fn);
                return self.parseFunctionDefinition(true);
            },
            .Use => return self.parseUse(),
        }
    }

    fn parseCurrent(self: *Parser) Node {
        const current = self.expectCurrent();
        switch (current) {
            .Constant => return self.parseExpr(),
            .Identifier => |id| return self.handleIdentifier(id),
            .Keyword => |keyword| return self.handleKeyword(keyword),
            .Format => {
                self.advance();
                return self.parseCurrent();
            },
            else => {
                std.log.err("Unexpected token '{full}'", .{current});
                @panic("");
            }
        }
    }

    pub fn parse(self: *Parser) NodeList {
        var nodes = NodeList.init(self.allocator);

        while (self.getCurrent() != null) {
            nodes.append(self.parseCurrent()) catch unreachable;
            // self.advance();
        }

        return nodes;
    }
};