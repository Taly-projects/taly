const std = @import("std");
const lexer = @import("lexer.zig");
const position = @import("position.zig");

pub const ValueNodeTag = enum {
    String,
    Int,
    Float,
    Bool,
};

pub const ValueNode = union(ValueNodeTag) {
    String: []const u8,
    Int: []const u8,
    Float: []const u8,
    Bool: bool,

    pub fn writeXML(self: *const ValueNode, writer: anytype, tabs: usize) anyerror!void {
        switch (self.*) {
            .String => |str| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<string>{s}</string>\n", .{str});
            },
            .Int => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<int>{s}</int>\n", .{num});
            },
            .Float => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<float>{s}</float>\n", .{num});
            },
            .Bool => |b| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<bool>{}</bool>\n", .{b});
            },
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
        try std.fmt.format(writer, "<path>{s}</path>\n", .{self.path});

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</use>\n");
    }
};

pub const ReturnNode = struct {
    value: ?*Node,

    pub fn writeXML(self: *const ReturnNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<return>\n");

        if (self.value) |value| {
            try value.writeXML(writer, tabs + 1);
        }

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</return>\n");
    }
};

pub const VariableDefinitionNode = struct {
    constant: bool,
    name: []const u8,
    data_type: []const u8,
    value: ?*Node,

    pub fn writeXML(self: *const VariableDefinitionNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<variable-def>\n");

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<constant>{}</constant>\n", .{self.constant});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
    
        try std.fmt.format(writer, "<data-type>{s}</data-type>\n", .{self.data_type});

        if (self.value) |value| {
            // Add tabs (+ 1)
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("<value>\n");

            try value.writeXML(writer, tabs + 2);

            // Add tabs (+ 1)
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("</value>\n");
        }

        // Add tabs
        i = 0;        
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</variable-def>\n");
    }
};

pub const VariableCallNode = struct {
    name: []const u8,

    pub fn writeXML(self: *const VariableCallNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<variable-call>{s}</variable-call>\n", .{self.name});
    }
};

pub const Operator = enum {
    Add,
    Subtract,
    Multiply,
    Divide,
    Assignment,
    Greater,
    GreaterOrEqual,
    Less,
    LessOrEqual,
    Equal,
    NotEqual,
    And,
    Or,
    Not,

    pub fn writeXML(self: *const Operator, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<operator>");
        switch (self.*) {
            .Add => try writer.writeAll("add"),
            .Subtract => try writer.writeAll("subtract"),
            .Multiply => try writer.writeAll("mutliply"),
            .Divide => try writer.writeAll("divide"),
            .Assignment => try writer.writeAll("assignment"),
            .Greater => try writer.writeAll("greater"),
            .GreaterOrEqual => try writer.writeAll("greater or equal"),
            .Less => try writer.writeAll("less"),
            .LessOrEqual => try writer.writeAll("less or equal"),
            .Equal => try writer.writeAll("equal"),
            .NotEqual => try writer.writeAll("not equal"),
            .And => try writer.writeAll("and"),
            .Or => try writer.writeAll("or"),
            .Not => try writer.writeAll("not"),
        }
        try writer.writeAll("</operator\n>");
    }
};

pub const BinaryOperationNode = struct {
    lhs: *Node,
    operator: Operator,
    rhs: *Node,

    pub fn writeXML(self: *const BinaryOperationNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<bin-op>\n");

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<lhs>\n");

        try self.lhs.writeXML(writer, tabs + 2);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</lhs>\n");

        try self.operator.writeXML(writer, tabs + 1);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<rhs>\n");

        try self.rhs.writeXML(writer, tabs + 2);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</rhs>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</bin-op>\n");

    }
};

pub const UnaryOperationNode = struct {
    operator: Operator,
    value: *Node,

    pub fn writeXML(self: *const UnaryOperationNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<unary-op>\n");

        try self.operator.writeXML(writer, tabs + 1);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<value>\n");

        try self.value.writeXML(writer, tabs + 2);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</value>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</unary-op>\n");

    }
};

pub const IfBranch = struct {
    condition: *Node,
    body: NodeList,

    pub fn writeXML(self: *const IfBranch, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<branch>\n");

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<condition>\n");

        try self.condition.writeXML(writer, tabs + 2);

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</condition>\n");

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<body>\n");

        for (self.body.items) |node| {
            try node.writeXML(writer, tabs + 2);
        }

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</body>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</branch>\n");

    }    
};
pub const IfBranchList = std.ArrayList(IfBranch);

pub const IfNode = struct {
    if_branch: IfBranch,
    elif_branches: IfBranchList,
    else_body: NodeList,

    pub fn writeXML(self: *const IfNode, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try writer.writeAll("<if>\n");

        try self.if_branch.writeXML(writer, tabs + 1);

        for (self.elif_branches.items) |branch| {
            try branch.writeXML(writer, tabs + 1);
        } 

        if (self.else_body.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("<else>\n");

            for (self.if_branch.body.items) |node| {
                try node.writeXML(writer, tabs + 2);
            }

            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("</else>\n");
        }

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</if>\n");

    }    
};

pub const NodeTag = enum {
    Value,
    FunctionDefinition,
    FunctionCall,
    Use,
    Return,
    VariableDefinition,
    VariableCall,
    BinaryOperation,
    UnaryOperation,
    If,
};

pub const Node = union(NodeTag) {
    Value: ValueNode,
    FunctionDefinition: FunctionDefinitionNode,
    FunctionCall: FunctionCallNode,
    Use: UseNode,
    Return: ReturnNode,
    VariableDefinition: VariableDefinitionNode,
    VariableCall: VariableCallNode,
    BinaryOperation: BinaryOperationNode,
    UnaryOperation: UnaryOperationNode,
    If: IfNode,

    pub fn writeXML(self: *const Node, writer: anytype, tabs: usize) anyerror!void {
        switch (self.*) {
            .Value => |node| return node.writeXML(writer, tabs),
            .FunctionDefinition => |node| return node.writeXML(writer, tabs),
            .FunctionCall => |node| return node.writeXML(writer, tabs),
            .Use => |node| return node.writeXML(writer, tabs),
            .Return => |node| return node.writeXML(writer, tabs),
            .VariableDefinition => |node| return node.writeXML(writer, tabs),
            .VariableCall => |node| return node.writeXML(writer, tabs),
            .BinaryOperation => |node| return node.writeXML(writer, tabs),
            .UnaryOperation => |node| return node.writeXML(writer, tabs),
            .If => |node| return node.writeXML(writer, tabs),
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
            .Return => |node| node.writeXML(writer, 0) catch unreachable,
            .VariableDefinition => |node| node.writeXML(writer, 0) catch unreachable,
            .VariableCall => |node| node.writeXML(writer, 0) catch unreachable,
            .BinaryOperation => |node| node.writeXML(writer, 0) catch unreachable,
            .UnaryOperation => |node| node.writeXML(writer, 0) catch unreachable,
            .If => |node| node.writeXML(writer, 0) catch unreachable,
        }
    }
};

pub const NodeList = std.ArrayList(Node);

pub const Parser = struct {
    file_name: []const u8,
    src: []const u8,
    allocator: std.mem.Allocator,
    tokens: lexer.TokenList,
    index: usize = 0,
    tabs: usize = 0,

    pub fn init(file_name: []const u8, src: []const u8, tokens: lexer.TokenList, allocator: std.mem.Allocator) Parser {
        return . {
            .file_name = file_name,
            .src = src,
            .allocator = allocator,
            .tokens = tokens,
        };
    }

    fn getCurrent(self: *const Parser) ?lexer.PositionedToken {
        if (self.index >= self.tokens.items.len) return null;
        return self.tokens.items[self.index];
    }

    fn peek(self: *const Parser, offset: usize) ?lexer.PositionedToken {
        if (self.index + offset >= self.tokens.items.len) return null;
        return self.tokens.items[self.index + offset];
    }

    fn expectCurrent(self: *const Parser, expected: ?[]const u8) lexer.PositionedToken {
        if (self.getCurrent()) |token| {
            return token;
        } else {
            if (expected) |e| {
                position.errorMessage("Unexpected EOF, should be '{s}'!", .{e}, self.file_name);
            } else {
                position.errorMessage("Unexpected EOF!", .{}, self.file_name);
            }
        }
    }

    fn expectIdentifier(self: *const Parser) []const u8 {
        if (self.getCurrent()) |token| {
            switch (token.data) {
                .Identifier => |id| return id,
                else => {
                    token.errorMessage("Unexpected token '{full}', should be 'Identifier'!", .{token.data}, self.src, self.file_name);
                }
            }
        } else {
            position.errorMessage("Unexpected EOF, should be 'Identifier'!", .{}, self.file_name);
        }
    }

    fn expectExactKeyword(self: *const Parser, keyword: lexer.TokenKeyword) void {
        if (self.getCurrent()) |token| {
            if (!token.data.isKeyword(keyword)) {
                token.errorMessage("Unexpected token '{full}', should be '{}'!", .{token.data, keyword}, self.src, self.file_name);
            }
        } else {
            position.errorMessage("Unexpected EOF, should be '{}'!", .{keyword}, self.file_name);
        }
    }

    fn expectSymbol(self: *const Parser, symbol: lexer.TokenSymbol) void {
        if (self.getCurrent()) |token| {
            if (!token.data.isSymbol(symbol)) {
                token.errorMessage("Unexpected token '{full}', should be '{}'!", .{token.data, symbol}, self.src, self.file_name);
            }
        } else {
            position.errorMessage("Unexpected EOF, should be '{}'!", .{symbol}, self.file_name);
        }
    }

    fn expectString(self: *const Parser) []const u8 {
        if (self.getCurrent()) |token| {
            switch (token.data) {
                .Constant => |constant| {
                    switch (constant) {
                        .String => |str| return str,
                        else => {
                            token.errorMessage("Unexpected token '{full}', should be 'String'!", .{token.data}, self.src, self.file_name);
                        }
                    }
                },
                else => {
                    token.errorMessage("Unexpected token '{full}', should be 'String'!", .{token.data}, self.src, self.file_name);
                }
            }
        } else {
            position.errorMessage("Unexpected EOF, should be 'String'!", .{}, self.file_name);
        }
    }

    fn expectEOS(self: *const Parser) void {
        if (self.getCurrent()) |current| {
            if (!current.data.isFormat(lexer.TokenFormat.NewLine)) {
                current.errorMessage("Unexpected token '{full}', should be 'NewLine'!", .{current.data}, self.src, self.file_name);
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
        var current = self.expectCurrent(")");
        while (!current.data.isSymbol(lexer.TokenSymbol.RightParenthesis)) {
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
            current = self.expectCurrent(")");
        }
        self.advance();

        var return_type: ?[]const u8 = null;
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.Colon)) {
                self.advance();
                return_type = self.expectIdentifier();
                self.advance();
            }
        }
        
        var body = NodeList.init(self.allocator);
        var last_index = self.index;
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.RightDoubleArrow)) {
                self.advance();
                self.tabs += 1;
                var tab_count: usize = 0;
                var first = true;
                while (self.getCurrent() != null) {
                    current = self.getCurrent().?;
                    if (current.data.isFormat(lexer.TokenFormat.Tab)) {
                        tab_count += 1;
                        self.advance();
                    } if (current.data.isFormat(lexer.TokenFormat.NewLine)) {
                        tab_count = 0;
                        first = false;
                        self.advance();
                    } else if (first or tab_count >= self.tabs) {
                        const node = self.parseCurrent();
                        body.append(node) catch unreachable;
                        last_index = self.index;
                    } else {
                        break;
                    }
                }
                self.tabs -= 1;
            }
        }
        self.index = last_index;

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

    fn parseValue(self: *Parser) Node {
        const current = self.expectCurrent("value");
        switch (current.data) {
            .Constant => |constant| return self.handleConstant(constant),
            .Identifier => |id| return self.handleIdentifier(id),
            .Keyword => |keyword| {
                if (keyword == lexer.TokenKeyword.Not) {
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseExpr();
                    return Node {
                        .UnaryOperation = .{
                            .operator = .Not,
                            .value = value
                        }
                    };
                } else {
                    current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data}, self.src, self.file_name);
                }
            },
            .Symbol => |symbol| {
                if (symbol == lexer.TokenSymbol.LeftParenthesis) {
                    self.advance();
                    const expr = self.parseExpr();
                    self.expectSymbol(lexer.TokenSymbol.RightParenthesis);
                    return expr;
                } else if (symbol == lexer.TokenSymbol.Plus) {
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseExpr();
                    return Node {
                        .UnaryOperation = .{
                            .operator = .Add,
                            .value = value
                        }
                    };
                } else if (symbol == lexer.TokenSymbol.Dash) {
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseExpr();
                    return Node {
                        .UnaryOperation = .{
                            .operator = .Subtract,
                            .value = value
                        }
                    };
                } else {
                    current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data}, self.src, self.file_name);
                }
            },
            else => {
                current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data}, self.src, self.file_name);
            }
        }
    }

    fn parseExpr0(self: *Parser) Node {
        var lhs = self.parseValue();
        self.advance();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.Equal)) {
                operator = Operator.Assignment;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr();
            self.advance();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            };
        }

        return lhs;
    }

    fn parseExpr1(self: *Parser) Node {
        var lhs = self.parseExpr0();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.Star)) {
                operator = Operator.Multiply;
            } else if (current.data.isSymbol(lexer.TokenSymbol.Slash)) {
                operator = Operator.Divide;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr0();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            };
        }

        return lhs;
    }

    fn parseExpr2(self: *Parser) Node {
        var lhs = self.parseExpr1();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.Plus)) {
                operator = Operator.Add;
            } else if (current.data.isSymbol(lexer.TokenSymbol.Dash)) {
                operator = Operator.Subtract;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr1();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            };
        }

        return lhs;
    }

    fn parseExpr3(self: *Parser) Node {
        var lhs = self.parseExpr2();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.RightAngle)) {
                operator = Operator.Greater;
            } else if (current.data.isSymbol(lexer.TokenSymbol.RightAngleEqual)) {
                operator = Operator.GreaterOrEqual;
            } else if (current.data.isSymbol(lexer.TokenSymbol.LeftAngle)) {
                operator = Operator.Less;
            } else if (current.data.isSymbol(lexer.TokenSymbol.LeftAngleEqual)) {
                operator = Operator.LessOrEqual;
            } else if (current.data.isSymbol(lexer.TokenSymbol.DoubleEqual)) {
                operator = Operator.Equal;
            } else if (current.data.isSymbol(lexer.TokenSymbol.ExclamationMarkEqual)) {
                operator = Operator.NotEqual;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr2();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            };
        }

        return lhs;
    }

    fn parseExpr4(self: *Parser) Node {
        var lhs = self.parseExpr3();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isKeyword(lexer.TokenKeyword.And)) {
                operator = Operator.And;
            } else if (current.data.isKeyword(lexer.TokenKeyword.Or)) {
                operator = Operator.Or;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr3();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            };
        }

        return lhs;
    }

    const parseExpr = parseExpr4;

    fn handleConstant(self: *Parser, value: lexer.TokenConstant) Node {
        _ = self;
        switch (value) {
            .String => |str| {
                return Node {
                    .Value = . {
                        .String = str
                    }
                };
            },
            .Int => |num| {
                return Node {
                    .Value = . {
                        .Int = num
                    }
                };
            },
            .Float => |num| {
                return Node {
                    .Value = . {
                        .Float = num
                    }
                };
            },
            .Bool => |b| {
                return Node {
                    .Value = . {
                        .Bool = b
                    }
                };
            },
        }
    }

    fn parseFunctionCall(self: *Parser, id: []const u8) Node {
        self.advance();
        var parameters = NodeList.init(self.allocator);
        var current = self.expectCurrent(")");
        while (!current.data.isSymbol(lexer.TokenSymbol.RightParenthesis)) {
            if (parameters.items.len != 0) {
                self.expectSymbol(lexer.TokenSymbol.Comma);
                self.advance();
            }
            const expr = self.parseExpr();
            parameters.append(expr) catch unreachable;
            current = self.expectCurrent(")");
        }
        
        return Node {
            .FunctionCall = .{
                .name = id,
                .parameters = parameters
            }
        };
    }

    fn handleIdentifier(self: *Parser, id: []const u8) Node {
        if (self.peek(1)) |next| {
            if (next.data.isSymbol(lexer.TokenSymbol.LeftParenthesis)) {
                self.advance();
                return self.parseFunctionCall(id);
            }
        }

        return Node {
            .VariableCall = . {
                .name = id
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

    fn parseReturn(self: *Parser) Node {
        self.advance();

        var value: ?*Node = null;
        if (self.getCurrent()) |current| {
            if (!current.data.isFormat(lexer.TokenFormat.NewLine)) {
                value = self.allocator.create(Node) catch unreachable;
                value.?.* = self.parseExpr();
            }
        }

        return Node {
            .Return = .{
                .value = value
            }
        };
    }

    fn parseVariableDefinition(self: *Parser, constant: bool) Node {
        self.advance();
        const name = self.expectIdentifier();
        self.advance();

        // Expexcted because no inference for now!
        self.expectSymbol(lexer.TokenSymbol.Colon);
        self.advance();
        const data_type = self.expectIdentifier();
        self.advance();

        var value: ?*Node = null;
        if (self.getCurrent() != null) {
            const current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.Equal)) {
                self.advance();
                value = self.allocator.create(Node) catch unreachable;
                value.?.* = self.parseExpr();
            }
        }

        return Node {
            .VariableDefinition = . {
                .constant = constant,
                .name = name,
                .data_type = data_type,
                .value = value
            }
        };
    }

    fn parseIfStatement(self: *Parser) Node {
        self.advance();
        var if_condition = self.allocator.create(Node) catch unreachable;
        if_condition.* = self.parseExpr();
        self.expectExactKeyword(lexer.TokenKeyword.Then);
        self.advance();

        var if_body = NodeList.init(self.allocator);
        var elif_branches = IfBranchList.init(self.allocator);
        var else_body = NodeList.init(self.allocator);

        const IfState = enum {
            If,
            Elif,
            Else
        };

        var state = IfState.If;

        var current = self.expectCurrent("end");
        while (true) {
            if (current.data.isFormat(lexer.TokenFormat.Tab) or current.data.isFormat(lexer.TokenFormat.NewLine)) {
                self.advance();
            } else if (current.data.isKeyword(lexer.TokenKeyword.End)) {
                break;
            } else if (current.data.isKeyword(lexer.TokenKeyword.Elif)) {
                if (state == IfState.Else) {
                    current.errorMessage("Unexpected elif branch after an else branch!", .{}, self.src, self.file_name);
                }

                self.advance();
                var condition = self.allocator.create(Node) catch unreachable;
                condition.* = self.parseExpr();
                self.expectExactKeyword(lexer.TokenKeyword.Then);
                self.advance();
                
                elif_branches.append(IfBranch {
                    .condition = condition,
                    .body = NodeList.init(self.allocator)
                }) catch unreachable;

                state = IfState.Elif;
            } else if (current.data.isKeyword(lexer.TokenKeyword.Else)) {
                self.advance();
                state = IfState.Else;
            } else {
                const node = self.parseCurrent();
                self.expectEOS();
                self.advance();
                switch (state) {
                    .If => if_body.append(node) catch unreachable,
                    .Elif => elif_branches.items[elif_branches.items.len - 1].body.append(node) catch unreachable,
                    .Else => else_body.append(node) catch unreachable
                }
            }

            current = self.expectCurrent("end");
        }
        self.advance();

        return Node {
            .If = IfNode {
                .if_branch = IfBranch {
                    .condition = if_condition,
                    .body = if_body
                },
                .elif_branches = elif_branches,
                .else_body = else_body
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
            .Return => return self.parseReturn(),
            .Const => return self.parseVariableDefinition(true),
            .Var => return self.parseVariableDefinition(false),
            .Not => return self.parseExpr(),
            .If => return self.parseIfStatement(),
            else => {
                const current = self.getCurrent().?;
                current.errorMessage("Unexpected token '{full}'!", .{current.data}, self.src, self.file_name);
            }
        }
    }

    fn parseCurrent(self: *Parser) Node {
        const current = self.expectCurrent(null);
        switch (current.data) {
            .Constant, .Identifier => return self.parseExpr(),
            .Keyword => |keyword| return self.handleKeyword(keyword),
            .Format => {
                self.advance();
                return self.parseCurrent();
            },
            .Symbol => |symbol| {
                switch (symbol) {
                    .LeftParenthesis, .Plus, .Dash => return self.parseExpr(),
                    else => {
                        current.errorMessage("Unexpected token '{full}'!", .{current.data}, self.src, self.file_name);
                    }
                }
            }
        }
    }

    pub fn parse(self: *Parser) NodeList {
        var nodes = NodeList.init(self.allocator);

        while (self.getCurrent() != null) {
            nodes.append(self.parseCurrent()) catch unreachable;
            self.expectEOS();
            self.advance();
        }

        return nodes;
    }
};