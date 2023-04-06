const std = @import("std");
const lexer = @import("lexer.zig");
const position = @import("position.zig");

const symbol = @import("symbol.zig");
pub usingnamespace symbol;

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

    pub fn writeXML(self: *const ValueNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        switch (self.*) {
            .String => |str| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<string id=\"{d}\">{s}</string>\n", .{id, str});
            },
            .Int => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<int id=\"{d}\">{s}</int>\n", .{id, num});
            },
            .Float => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<float id=\"{d}\">{s}</float>\n", .{id, num});
            },
            .Bool => |b| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                return std.fmt.format(writer, "<bool id=\"{d}\">{}</bool>\n", .{id, b});
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

        try std.fmt.format(writer, "<parameter>\n", .{});

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
    variadic: bool,
    return_type: ?[]const u8,
    external: bool,
    constructor: bool,
    body: NodeList,

    pub fn writeXML(self: *const FunctionDefinitionNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<function-def id=\"{d}\">\n", .{id});

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

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<variadic>{}</variadic>\n", .{self.variadic});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<constructor>{}</constructor>\n", .{self.constructor});

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

    pub fn writeXML(self: *const FunctionCallNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<function-call id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const UseNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<use id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const ReturnNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<return id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const VariableDefinitionNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<variable-def id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const VariableCallNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<variable-call id=\"{d}\">{s}</variable-call>\n", .{id, self.name});
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
    Access,

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
            .Access => try writer.writeAll("access"),
        }
        try writer.writeAll("</operator\n>");
    }
};

pub const BinaryOperationNode = struct {
    lhs: *Node,
    operator: Operator,
    rhs: *Node,

    pub fn writeXML(self: *const BinaryOperationNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<bin-op id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const UnaryOperationNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<unary-op id=\"{d}\">\n", .{id});

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

    pub fn writeXML(self: *const IfNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<if id=\"{d}\">\n", .{id});

        try self.if_branch.writeXML(writer, tabs + 1);

        for (self.elif_branches.items) |branch| {
            try branch.writeXML(writer, tabs + 1);
        } 

        if (self.else_body.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("<else>\n");

            for (self.else_body.items) |node| {
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

pub const WhileNode = struct {
    condition: *Node,
    body: NodeList,

    pub fn writeXML(self: *const WhileNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<while id=\"{d}\">\n", .{id});

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

        try writer.writeAll("</while>\n");

    }    
};

pub const LabelNode = struct {
    label: []const u8,

    pub fn writeXML(self: *const LabelNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<label id=\"{d}\">{s}</label>\n", .{id, self.label});
    }    

};

pub const ContinueNode = struct {
    label: ?[]const u8,

    pub fn writeXML(self: *const ContinueNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<continue id=\"{d}\">", .{id});
        if (self.label) |label| {
            try std.fmt.format(writer, "{s}", .{label});
        }
        try writer.writeAll("</continue>\n");
    }    

};

pub const BreakNode = struct {
    label: ?[]const u8,

    pub fn writeXML(self: *const BreakNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<break id=\"{d}\">", .{id});
        if (self.label) |label| {
            try std.fmt.format(writer, "{s}", .{label});
        }
        try writer.writeAll("</break>\n");
    }    

};

pub const MatchStatement = struct {
    condition: *Node,
    branches: IfBranchList,
    else_body: NodeList,

    pub fn writeXML(self: *const MatchStatement, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<match id=\"{d}\">\n", .{id});

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

        try writer.writeAll("<branches>\n");

        for (self.branches.items) |branch| {
            try branch.writeXML(writer, tabs + 2);
        }

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</branches>\n");  

        if (self.else_body.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

            try writer.writeAll("<else>\n");

            for (self.else_body.items) |node| {
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

        try writer.writeAll("</match>\n");      
    }
};

pub const ClassNode = struct {
    sealed: bool,
    name: []const u8,
    body: NodeList,

    pub fn writeXML(self: *const ClassNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<class id=\"{d}\">\n", .{id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<sealed>{}</sealed>", .{self.sealed});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>", .{self.name});

        if (self.body.items.len != 0) {
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
        }

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</class>\n");      
    }
};

pub const TypeNode = struct {
    name: []const u8,
    value: []const u8,

    pub fn writeXML(self: *const TypeNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<type-alias id=\"{d}\">\n", .{id});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs (+ 1)
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        
        try std.fmt.format(writer, "<value>{s}</value>\n", .{self.value});

        // Add tabs
        i = 0;        
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</type-alias>\n");
    }

};

pub const ExtendStatementNode = struct {
    name: []const u8,
    body: NodeList,

    pub fn writeXML(self: *const ExtendStatementNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<extend id=\"{d}\">\n", .{id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>", .{self.name});

        if (self.body.items.len != 0) {
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
        }

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</extend>\n");      
    }
    
};

// Compiler Instruction - Pure C
pub const CI_PureCNode = struct {
    code: []const u8,

    pub fn writeXML(self: *const CI_PureCNode, writer: anytype, tabs: usize, id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<ci-pure-c id=\"{d}\">{s}</ci-pure-c>\n", .{id, self.code});
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
    While,
    Label,
    Continue,
    Break,
    Match,
    Class,
    Type,
    ExtendStatement,
    CI_PureC,
};

pub const NodeData = union(NodeTag) {
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
    While: WhileNode,
    Label: LabelNode,
    Continue: ContinueNode,
    Break: BreakNode,
    Match: MatchStatement,
    Class: ClassNode,
    Type: TypeNode,
    ExtendStatement: ExtendStatementNode,
    CI_PureC: CI_PureCNode,

    pub fn makeNode(self: NodeData) Node {
        return Node.gen(self);
    } 

    pub fn writeXML(self: *const NodeData, writer: anytype, tabs: usize, id: usize) anyerror!void {
        switch (self.*) {
            .Value => |node| return node.writeXML(writer, tabs, id),
            .FunctionDefinition => |node| return node.writeXML(writer, tabs, id),
            .FunctionCall => |node| return node.writeXML(writer, tabs, id),
            .Use => |node| return node.writeXML(writer, tabs, id),
            .Return => |node| return node.writeXML(writer, tabs, id),
            .VariableDefinition => |node| return node.writeXML(writer, tabs, id),
            .VariableCall => |node| return node.writeXML(writer, tabs, id),
            .BinaryOperation => |node| return node.writeXML(writer, tabs, id),
            .UnaryOperation => |node| return node.writeXML(writer, tabs, id),
            .If => |node| return node.writeXML(writer, tabs, id),
            .While => |node| return node.writeXML(writer, tabs, id),
            .Label => |node| return node.writeXML(writer, tabs, id),
            .Continue => |node| return node.writeXML(writer, tabs, id),
            .Break => |node| return node.writeXML(writer, tabs, id),
            .Match => |node| return node.writeXML(writer, tabs, id),
            .Class => |node| return node.writeXML(writer, tabs, id),
            .Type => |node| return node.writeXML(writer, tabs, id),
            .ExtendStatement => |node| return node.writeXML(writer, tabs, id),
            .CI_PureC => |node| return node.writeXML(writer, tabs, id),
        }
    }

    pub fn format(self: *const NodeData, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;
        _ = fmt;

        // self.writeXML(writer, 0);

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
            .While => |node| node.writeXML(writer, 0) catch unreachable,
            .Label => |node| node.writeXML(writer, 0) catch unreachable,
            .Continue => |node| node.writeXML(writer, 0) catch unreachable,
            .Break => |node| node.writeXML(writer, 0) catch unreachable,
            .Match => |node| node.writeXML(writer, 0) catch unreachable,
            .Class => |node| node.writeXML(writer, 0) catch unreachable,
            .Type => |node| node.writeXML(writer, 0) catch unreachable,
            .ExtendStatement => |node| node.writeXML(writer, 0) catch unreachable,
            .CI_PureC => |node| node.writeXML(writer, 0) catch unreachable,
        }
    }
};

pub const Node = struct {
    pub const NO_ID: usize = 0;
    var ID: usize = 1;

    data: NodeData,
    id: usize,

    pub fn gen(data: NodeData) Node {
        const self = Node {
            .data = data,
            .id = ID
        };
        ID += 1;
        return self;
    }

    pub fn writeXML(self: *const Node, writer: anytype, tabs: usize) anyerror!void {
        return self.data.writeXML(writer, tabs, self.id);
    }

    pub fn format(self: *const Node, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        return self.data.format(fmt, options, writer);
    }
};

pub const NodeList = std.ArrayList(Node);

pub const NodeInfo = struct {
    node_id: usize,
    position: position.Positioned(void),
    symbol_def: ?usize = null,
    symbol_call: ?usize = null,
    data_type: ?[]const u8 = null,
    renamed: ?[]const u8 = null,
    aside_symbols: ?symbol.SymbolList = null,

    pub fn writeXML(self: *const NodeInfo, writer: anytype) anyerror!void {
        try std.fmt.format(writer, "<node-info id=\"{d}\">\n", .{self.node_id});
        
        try writer.writeAll("\t<position>\n");
        try std.fmt.format(writer, "\t\t<start line=\"{d}\" column=\"{d}\"/>\n", .{self.position.start.line + 1, self.position.start.column_index + 1});
        try std.fmt.format(writer, "\t\t<end line=\"{d}\" column=\"{d}\"/>\n", .{self.position.end.line + 1, self.position.end.column_index + 1});
        try writer.writeAll("\t</position>\n");

        if (self.symbol_def) |symbol_def| {
            try std.fmt.format(writer, "\t<symbol-def symbol-id=\"{d}\"/>\n", .{symbol_def});
        }

        if (self.symbol_call) |symbol_call| {
            try std.fmt.format(writer, "\t<symbol-call symbol-id=\"{d}\"/>\n", .{symbol_call});
        }

        if (self.data_type) |data_type| {
            try std.fmt.format(writer, "\t<type>{s}</type>\n", .{data_type});
        }

        if (self.renamed) |renamed| {
            try std.fmt.format(writer, "\t<renamed>{s}</renamed>\n", .{renamed});
        }

        if (self.aside_symbols) |aside| {
            try std.fmt.format(writer, "\t<aside-symbols>{}</aside-symbols>\n", .{aside.items.len});
        }

        try writer.writeAll("</node-info>\n");
    }

};

pub const NodeInfos = std.ArrayList(NodeInfo);

pub const Parser = struct {
    file_name: []const u8,
    src: []const u8,
    allocator: std.mem.Allocator,
    tokens: lexer.TokenList,
    index: usize = 0,
    tabs: usize = 0,
    infos: NodeInfos,
    symbols: symbol.SymbolList,

    pub fn init(file_name: []const u8, src: []const u8, tokens: lexer.TokenList, allocator: std.mem.Allocator) Parser {
        const infos = NodeInfos.init(allocator);
        const symbols = symbol.SymbolList.init(allocator);
        return . {
            .file_name = file_name,
            .src = src,
            .allocator = allocator,
            .tokens = tokens,
            .infos = infos,
            .symbols = symbols,
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
                    token.errorMessage("Unexpected token '{full}', should be 'Identifier'!", .{token.data});
                }
            }
        } else {
            position.errorMessage("Unexpected EOF, should be 'Identifier'!", .{}, self.file_name);
        }
    }

    fn expectExactKeyword(self: *const Parser, keyword: lexer.TokenKeyword) void {
        if (self.getCurrent()) |token| {
            if (!token.data.isKeyword(keyword)) {
                token.errorMessage("Unexpected token '{full}', should be '{}'!", .{token.data, keyword});
            }
        } else {
            position.errorMessage("Unexpected EOF, should be '{}'!", .{keyword}, self.file_name);
        }
    }

    fn expectSymbol(self: *const Parser, sym: lexer.TokenSymbol) void {
        if (self.getCurrent()) |token| {
            if (!token.data.isSymbol(sym)) {
                token.errorMessage("Unexpected token '{full}', should be '{}'!", .{token.data, symbol});
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
                            token.errorMessage("Unexpected token '{full}', should be 'String'!", .{token.data});
                        }
                    }
                },
                else => {
                    token.errorMessage("Unexpected token '{full}', should be 'String'!", .{token.data});
                }
            }
        } else {
            position.errorMessage("Unexpected EOF, should be 'String'!", .{}, self.file_name);
        }
    }

    fn expectEOS(self: *const Parser) void {
        if (self.getCurrent()) |current| {
            if (!current.data.isFormat(lexer.TokenFormat.NewLine)) {
                current.errorMessage("Unexpected token '{full}', should be 'NewLine'!", .{current.data});
            } 
        } 
    }

    fn advance(self: *Parser) void {
        self.index += 1;
    }

    fn get_infos(self: *Parser, id: usize) *NodeInfo {
        for (self.infos.items) |*info| {
            if (info.node_id == id) return info;
        }

        unreachable;
    }

    fn parseFunctionDefinition(self: *Parser, external: bool, constructor: bool, start: position.Position) Node {
        self.advance();
        const id = self.expectIdentifier();
        self.advance();

        self.expectSymbol(lexer.TokenSymbol.LeftParenthesis);
        self.advance();
        var parameters = FunctionDefinitionParameters.init(self.allocator);
        var current = self.expectCurrent(")");
        var variadic = false;
        while (!current.data.isSymbol(lexer.TokenSymbol.RightParenthesis)) {
            if (parameters.items.len != 0) {
                self.expectSymbol(lexer.TokenSymbol.Comma);
                self.advance();
            }
            if (external and self.expectCurrent(")").data.isSymbol(lexer.TokenSymbol.TripleDot)) {
                variadic = true;
                self.advance();
                self.expectSymbol(lexer.TokenSymbol.RightParenthesis);
                break;
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
        var end = self.getCurrent().?.end;
        self.advance();

        var return_type: ?[]const u8 = null;
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.Colon)) {
                self.advance();
                return_type = self.expectIdentifier();
                end = self.getCurrent().?.end;
                self.advance();
            }
        }

        // Generate symbol
        const sym_count = self.symbols.items.len;
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Function = symbol.FunctionSymbol {
                .external = external,
                .constructor = constructor,
                .name = id,
                .parameters = parameters,
                .return_type = return_type,
                .children = symbol.SymbolList.init(self.allocator)
            }
        }, symbol.Symbol.NO_ID);
        self.symbols.append(sym) catch unreachable;

        var body = NodeList.init(self.allocator);
        var last_index = self.index;
        if (self.getCurrent() != null) {
            current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.RightDoubleArrow)) {
                end = self.getCurrent().?.end;
                self.advance();
                last_index = self.index;
                self.tabs += 1;
                var tab_count: usize = 0;
                var first = true;
                while (self.getCurrent() != null) {
                    current = self.getCurrent().?;
                    if (current.data.isFormat(lexer.TokenFormat.Tab)) {
                        tab_count += 1;
                        self.advance();
                    } else if (current.data.isFormat(lexer.TokenFormat.NewLine)) {
                        tab_count = 0;
                        first = false;
                        self.advance();
                    } else if (first or tab_count >= self.tabs) {
                        const node = self.parseCurrent();
                        body.append(node) catch unreachable;
                        
                        // Update end position
                        end = self.get_infos(node.id).position.end;

                        last_index = self.index;
                    } else {
                        break;
                    }
                }
                self.tabs -= 1;
            }
        }
        self.index = last_index;

        const node = Node.gen(NodeData {
            .FunctionDefinition = . {
                .name = id,
                .parameters = parameters,
                .return_type = return_type,
                .external = external,
                .variadic = variadic,
                .constructor = constructor,
                .body = body
            }
        });

        // Update symbol ID
        const symbol_ref = &self.symbols.items[sym_count];
        symbol_ref.node_id = node.id;
        symbol_ref.data.Function.variadic = variadic;

        // Pop all children
        var i: usize = self.symbols.items.len;
        while (i > sym_count + 1) {
            const child = self.symbols.pop();
            symbol_ref.data.Function.children.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end),
            .symbol_def = sym.id
        }) catch unreachable;

        return node;
    }

    fn parseValue(self: *Parser) Node {
        const current = self.expectCurrent("value");
        switch (current.data) {
            .Constant => |constant| return self.handleConstant(constant),
            .Identifier => |id| return self.handleIdentifier(id),
            .Keyword => |keyword| {
                if (keyword == lexer.TokenKeyword.Not) {
                    const start = current.start;
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseValue();
                    const node = Node.gen(NodeData {
                        .UnaryOperation = .{
                            .operator = .Not,
                            .value = value
                        }
                    });

                    // Get positions
                    const end = self.get_infos(value.id).position.end;

                    // Generate node informations
                    self.infos.append(NodeInfo {
                        .node_id = node.id,
                        .position = position.Positioned(void).init(void {}, start, end)
                    }) catch unreachable;

                    return node;
                } else {
                    current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data});
                }
            },
            .Symbol => |sym| {
                if (sym == lexer.TokenSymbol.LeftParenthesis) {
                    const start = current.start;
                    self.advance();
                    const expr = self.parseExpr();
                    self.expectSymbol(lexer.TokenSymbol.RightParenthesis);
                    const end = self.getCurrent().?.end;

                    // Generate node informations
                    const pos = &self.get_infos(expr.id).position;
                    pos.start = start;
                    pos.end = end;

                    return expr;
                } else if (sym == lexer.TokenSymbol.Plus) {
                    const start = current.start;
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseExpr();
                    const node = Node.gen(NodeData {
                        .UnaryOperation = .{
                            .operator = .Add,
                            .value = value
                        }
                    });

                    // Get positions
                    const end = self.get_infos(value.id).position.end;

                    // Generate node informations
                    self.infos.append(NodeInfo {
                        .node_id = node.id,
                        .position = position.Positioned(void).init(void {}, start, end)
                    }) catch unreachable;

                    return node;
                } else if (sym == lexer.TokenSymbol.Dash) {
                    const start = current.start;
                    self.advance();
                    var value = self.allocator.create(Node) catch unreachable;
                    value.* = self.parseExpr();
                    const node = Node.gen(NodeData {
                        .UnaryOperation = .{
                            .operator = .Subtract,
                            .value = value
                        }
                    });

                    // Get positions
                    const end = self.get_infos(value.id).position.end;

                    // Generate node informations
                    self.infos.append(NodeInfo {
                        .node_id = node.id,
                        .position = position.Positioned(void).init(void {}, start, end)
                    }) catch unreachable;

                    return node;
                } else {
                    current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data});
                }
            },
            else => {
                current.errorMessage("Unexpected token '{full}', should be 'Expression'!", .{current.data});
            }
        }
    }

    fn parseExpr0(self: *Parser) Node {
        var lhs = self.parseValue();
        self.advance();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.Dot)) {
                operator = Operator.Access;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseValue();
            self.advance();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node.gen(NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    fn parseExpr1(self: *Parser) Node {
        var lhs = self.parseExpr0();

        while (self.getCurrent()) |current| {
            var operator: Operator = undefined;
            if (current.data.isSymbol(lexer.TokenSymbol.Equal)) {
                operator = Operator.Assignment;
            } else {
                break;
            }
            self.advance();
            const rhs = self.parseExpr();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node.gen(NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    fn parseExpr2(self: *Parser) Node {
        var lhs = self.parseExpr1();

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
            const rhs = self.parseExpr1();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node.gen(NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    fn parseExpr3(self: *Parser) Node {
        var lhs = self.parseExpr2();

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
            const rhs = self.parseExpr2();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node.gen(NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    fn parseExpr4(self: *Parser) Node {
        var lhs = self.parseExpr3();

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
            const rhs = self.parseExpr3();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            lhs = Node.gen (NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    fn parseExpr5(self: *Parser) Node {
        var lhs = self.parseExpr4();

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
            const rhs = self.parseExpr4();

            var lhs_alloc = self.allocator.create(Node) catch unreachable;
            lhs_alloc.* = lhs;
            var rhs_alloc = self.allocator.create(Node) catch unreachable;
            rhs_alloc.* = rhs;

            // Generate node
            lhs = Node.gen(NodeData {
                .BinaryOperation = . {
                    .lhs = lhs_alloc,
                    .operator = operator,
                    .rhs = rhs_alloc
                }
            });

            // Get positions
            const start = self.get_infos(lhs_alloc.id).position.start;
            const end = self.get_infos(rhs_alloc.id).position.end;
        
            // Generate node informations
            self.infos.append(NodeInfo {
                .node_id = lhs.id,
                .position = position.Positioned(void).init(void {}, start, end)
            }) catch unreachable;
        }

        return lhs;
    }

    const parseExpr = parseExpr5;

    fn handleConstant(self: *Parser, value: lexer.TokenConstant) Node {
        switch (value) {
            .String => |str| {
                // Generate node
                const node = Node.gen(NodeData {
                    .Value = . {
                        .String = str
                    }
                });

                // Get position
                const start = self.getCurrent().?.start;
                const end = self.getCurrent().?.end;

                // Generate node informations
                self.infos.append(NodeInfo {
                    .node_id = node.id,
                    .position = position.Positioned(void).init(void {}, start, end)
                }) catch unreachable;

                return node;
            },
            .Int => |num| {
                const node = Node.gen(NodeData {
                    .Value = . {
                        .Int = num
                    }
                });

                // Get position
                const start = self.getCurrent().?.start;
                const end = self.getCurrent().?.end;

                // Generate node informations
                self.infos.append(NodeInfo {
                    .node_id = node.id,
                    .position = position.Positioned(void).init(void {}, start, end)
                }) catch unreachable;

                return node;
            },
            .Float => |num| {
                const node = Node.gen(NodeData {
                    .Value = . {
                        .Float = num
                    }
                });

                // Get position
                const start = self.getCurrent().?.start;
                const end = self.getCurrent().?.end;

                // Generate node informations
                self.infos.append(NodeInfo {
                    .node_id = node.id,
                    .position = position.Positioned(void).init(void {}, start, end)
                }) catch unreachable;

                return node;
            },
            .Bool => |b| {
                const node = Node.gen(NodeData {
                    .Value = . {
                        .Bool = b
                    }
                });

                // Get position
                const start = self.getCurrent().?.start;
                const end = self.getCurrent().?.end;

                // Generate node informations
                self.infos.append(NodeInfo {
                    .node_id = node.id,
                    .position = position.Positioned(void).init(void {}, start, end)
                }) catch unreachable;

                return node;
            },
        }
    }

    fn parseFunctionCall(self: *Parser, id: []const u8, start: position.Position) Node {
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
        const end = self.getCurrent().?.end;
        
        // Generate node
        const node = Node.gen(NodeData {
            .FunctionCall = .{
                .name = id,
                .parameters = parameters
            }
        });

        // Generate informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn handleIdentifier(self: *Parser, id: []const u8) Node {
        if (self.peek(1)) |next| {
            if (next.data.isSymbol(lexer.TokenSymbol.LeftParenthesis)) {
                const start = self.getCurrent().?.start;
                self.advance();
                return self.parseFunctionCall(id, start);
            }
        }

        // Generate node
        const node = Node.gen(NodeData {
            .VariableCall = . {
                .name = id
            }
        });

        // Get start end end position
        const start = self.getCurrent().?.start;
        const end = self.getCurrent().?.end;

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseUse(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        const path = self.expectString();
        const end = self.getCurrent().?.end;
        self.advance();

        const node = Node.gen(NodeData {
            .Use = .{
                .path = path
            }
        });

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseReturn(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        var end = self.getCurrent().?.end;
        self.advance();

        var value: ?*Node = null;
        if (self.getCurrent()) |current| {
            if (!current.data.isFormat(lexer.TokenFormat.NewLine)) {
                value = self.allocator.create(Node) catch unreachable;
                value.?.* = self.parseExpr();
                
                // Update end position
                end = self.get_infos(value.?.id).position.end;
            }
        }

        const node = Node.gen(NodeData {
            .Return = .{
                .value = value
            }
        });

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseVariableDefinition(self: *Parser, constant: bool, start: position.Position) Node {
        self.advance();
        const name = self.expectIdentifier();
        var end = self.getCurrent().?.end;
        self.advance();

        // Expexcted because no inference for now!
        self.expectSymbol(lexer.TokenSymbol.Colon);
        self.advance();
        const data_type = self.expectIdentifier();
        end = self.getCurrent().?.end;
        self.advance();

        var value: ?*Node = null;
        if (self.getCurrent() != null) {
            const current = self.getCurrent().?;
            if (current.data.isSymbol(lexer.TokenSymbol.Equal)) {
                self.advance();
                value = self.allocator.create(Node) catch unreachable;
                value.?.* = self.parseExpr();
                end = self.get_infos(value.?.id).position.end;
            }
        }

        const node = Node.gen(NodeData {
            .VariableDefinition = . {
                .constant = constant,
                .name = name,
                .data_type = data_type,
                .value = value
            }
        });

        // Generate symbol
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Variable = symbol.VariableSymbol {
                .name = name,
                .data_type = data_type,
                .constant = constant,
                .initialized = value == null,
            }
        }, node.id);
        self.symbols.append(sym) catch unreachable;

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end),
            .symbol_def = sym.id,
        }) catch unreachable;

        return node;
    }

    fn parseIfStatement(self: *Parser) Node {
        const start = self.getCurrent().?.start;
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

        // Generate symbol
        const sym_count = self.symbols.items.len;
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Block = symbol.BlockSymbol {
                .children = symbol.SymbolList.init(self.allocator),
            }
        }, symbol.Symbol.NO_ID);
        self.symbols.append(sym) catch unreachable;

        var current = self.expectCurrent("end");
        while (true) {
            if (current.data.isFormat(lexer.TokenFormat.Tab) or current.data.isFormat(lexer.TokenFormat.NewLine)) {
                self.advance();
            } else if (current.data.isKeyword(lexer.TokenKeyword.End)) {
                break;
            } else if (current.data.isKeyword(lexer.TokenKeyword.Elif)) {
                if (state == IfState.Else) {
                    current.errorMessage("Unexpected elif branch after an else branch!", .{});
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
                // self.expectEOS();
                self.advance();
                switch (state) {
                    .If => if_body.append(node) catch unreachable,
                    .Elif => elif_branches.items[elif_branches.items.len - 1].body.append(node) catch unreachable,
                    .Else => else_body.append(node) catch unreachable
                }
            }

            current = self.expectCurrent("end");
        }
        const end = self.getCurrent().?.end;
        self.advance();

        // Generate node
        const node = Node.gen(NodeData {
            .If = IfNode {
                .if_branch = IfBranch {
                    .condition = if_condition,
                    .body = if_body
                },
                .elif_branches = elif_branches,
                .else_body = else_body
            }
        });

        // Update symbol ID
        const symbol_ref = &self.symbols.items[sym_count];
        symbol_ref.node_id = node.id;

        // Pop all children
        var i: usize = self.symbols.items.len;
        while (i > sym_count + 1) {
            const child = self.symbols.pop();
            symbol_ref.data.Class.children.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseWhileLoop(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        var condition = self.allocator.create(Node) catch unreachable;
        condition.* = self.parseExpr();
        self.expectExactKeyword(lexer.TokenKeyword.Do);
        self.advance();

        // Generate symbol
        const sym_count = self.symbols.items.len;
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Block = symbol.BlockSymbol {
                .children = symbol.SymbolList.init(self.allocator),
            }
        }, symbol.Symbol.NO_ID);
        self.symbols.append(sym) catch unreachable;

        var body = NodeList.init(self.allocator);
        var current = self.expectCurrent("end");
        self.tabs += 1;
        while (!current.data.isKeyword(lexer.TokenKeyword.End)) {
            if (current.data.isFormat(lexer.TokenFormat.Tab) or current.data.isFormat(lexer.TokenFormat.NewLine)) {
                self.advance();
                current = self.expectCurrent("end");
            } else {
                body.append(self.parseCurrent()) catch unreachable;
                current = self.expectCurrent("end");
            }
        }
        self.tabs -= 1;
        const end = self.getCurrent().?.end;
        self.advance();

        // Generate node
        const node = Node.gen(NodeData {
            .While = WhileNode {
                .condition = condition,
                .body = body
            }
        });

        // Update symbol ID
        const symbol_ref = &self.symbols.items[sym_count];
        symbol_ref.node_id = node.id;

        // Pop all children
        var i: usize = self.symbols.items.len;
        while (i > sym_count + 1) {
            const child = self.symbols.pop();
            symbol_ref.data.Class.children.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;
        

        return node;
    }

    fn parseContinue(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        var end = self.getCurrent().?.end;
        self.advance();
        var label: ?[]const u8 = null;
        if (self.getCurrent()) |token| {
            switch (token.data) {
                .Label => |lbl| {
                    label = lbl;
                    end = token.end;
                    self.advance();
                },
                else => {}
            }
        }

        const node = Node.gen(NodeData {
            .Continue = ContinueNode {
                .label = label
            }
        });

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseBreak(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        var end = self.getCurrent().?.end;
        self.advance();
        var label: ?[]const u8 = null;
        if (self.getCurrent()) |token| {
            switch (token.data) {
                .Label => |lbl| {
                    label = lbl;
                    end = token.end;
                    self.advance();
                },
                else => {}
            }
        }

        const node = Node.gen(NodeData {
            .Break = BreakNode {
                .label = label
            }
        });

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseMatch(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        var condition = self.allocator.create(Node) catch unreachable;
        condition.* = self.parseExpr();
        self.expectEOS();

        // Generate symbol
        const sym_count = self.symbols.items.len;
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Block = symbol.BlockSymbol {
                .children = symbol.SymbolList.init(self.allocator),
            }
        }, symbol.Symbol.NO_ID);
        self.symbols.append(sym) catch unreachable;

        var tabs: usize = 0;
        var branches = IfBranchList.init(self.allocator);
        var else_body = NodeList.init(self.allocator);
        self.tabs += 1;
        while (true) {
            var current = self.expectCurrent("end");
            if (current.data.isFormat(lexer.TokenFormat.Tab)) {
                tabs += 1;
                self.advance();
                continue;
            } else if (current.data.isFormat(lexer.TokenFormat.NewLine)) {
                tabs = 0;
                self.advance();
                continue;
            } else if (current.data.isKeyword(lexer.TokenKeyword.Else)) {
                self.advance();
                while (!current.data.isKeyword(lexer.TokenKeyword.End)) {
                    if (current.data.isFormat(lexer.TokenFormat.Tab) or current.data.isFormat(lexer.TokenFormat.NewLine)) {
                        self.advance();
                        current = self.expectCurrent("end");
                        continue;
                    }
                    else_body.append(self.parseCurrent()) catch unreachable;
                    current = self.expectCurrent("end");
                }
                break;
            } else if (current.data.isKeyword(lexer.TokenKeyword.End)) {
                break;
            }

            if (tabs == self.tabs) {
                var expr = self.allocator.create(Node) catch unreachable;
                expr.* = self.parseExpr();
                self.expectSymbol(lexer.TokenSymbol.RightDoubleArrow);
                self.advance();
                self.tabs += 1;
                var tab_count: usize = 0;
                var first = true;
                var body = NodeList.init(self.allocator);
                var last_index = self.index;
                while (true) {
                    current = self.expectCurrent("end");
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
                self.index = last_index;
                branches.append(IfBranch {
                    .condition = expr,
                    .body = body,
                }) catch unreachable;
            } else {
                std.log.info("tabs: {} / {}", .{tabs, self.tabs});
                current.errorMessage("Unexpected token '{full}', should be 'Tab' or 'end'", .{current.data});
            }
        }
        self.tabs -= 1;
        const end = self.getCurrent().?.end;
        self.advance();

        // Generate node
        const node = Node.gen(NodeData {
            .Match = MatchStatement {
                .condition = condition,
                .branches = branches,
                .else_body = else_body,
            }
        });

        // Update symbol ID
        const symbol_ref = &self.symbols.items[sym_count];
        symbol_ref.node_id = node.id;

        // Pop all children
        var i: usize = self.symbols.items.len;
        while (i > sym_count + 1) {
            const child = self.symbols.pop();
            symbol_ref.data.Class.children.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
    }

    fn parseClass(self:* Parser, start: position.Position, sealed: bool) Node {
        self.advance();
        const name = self.expectIdentifier();
        var end = self.getCurrent().?.end;
        self.advance();

        // Generate symbol
        const sym_count = self.symbols.items.len;
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .Class = symbol.ClassSymbol {
                .sealed = sealed,
                .name = name,
                .children = symbol.SymbolList.init(self.allocator),
            }
        }, symbol.Symbol.NO_ID);
        self.symbols.append(sym) catch unreachable;

        self.tabs += 1;
        var tab_count: usize = 0;
        var first = true;
        var body = NodeList.init(self.allocator);
        var last_index = self.index;
        while (self.getCurrent() != null) {
            const current = self.getCurrent().?;
            if (current.data.isFormat(lexer.TokenFormat.Tab)) {
                tab_count += 1;
                self.advance();
            } else if (current.data.isFormat(lexer.TokenFormat.NewLine)) {
                tab_count = 0;
                first = false;
                self.advance();
            } else if (first or tab_count >= self.tabs) {
                const node = self.parseCurrent();
                body.append(node) catch unreachable;
                last_index = self.index;
                end = self.get_infos(node.id).position.end;
            } else {
                break;
            }
        }
        self.tabs -= 1;
        self.index = last_index;

        const node = Node.gen(NodeData {
            .Class = ClassNode {
                .sealed = sealed,
                .name = name,
                .body = body
            }
        });

        // Update symbol ID
        const symbol_ref = &self.symbols.items[sym_count];
        symbol_ref.node_id = node.id;

        // Pop all children
        var i: usize = self.symbols.items.len;
        while (i > sym_count + 1) {
            const child = self.symbols.pop();
            symbol_ref.data.Class.children.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end),
            .symbol_def = sym.id
        }) catch unreachable;

        return node;
    }

    fn parseExtend(self:* Parser) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        const name = self.expectIdentifier();
        var end = self.getCurrent().?.end;
        self.advance();

        // Generate symbol
        const sym_count = self.symbols.items.len;

        self.tabs += 1;
        var tab_count: usize = 0;
        var first = true;
        var body = NodeList.init(self.allocator);
        var last_index = self.index;
        while (self.getCurrent() != null) {
            const current = self.getCurrent().?;
            if (current.data.isFormat(lexer.TokenFormat.Tab)) {
                tab_count += 1;
                self.advance();
            } else if (current.data.isFormat(lexer.TokenFormat.NewLine)) {
                tab_count = 0;
                first = false;
                self.advance();
            } else if (first or tab_count >= self.tabs) {
                const node = self.parseCurrent();
                body.append(node) catch unreachable;
                last_index = self.index;
                end = self.get_infos(node.id).position.end;
            } else {
                break;
            }
        }
        self.tabs -= 1;
        self.index = last_index;

        const node = Node.gen(NodeData {
            .ExtendStatement = ExtendStatementNode {
                .name = name,
                .body = body
            }
        });

        // Pop all children
        var symbols = symbol.SymbolList.init(self.allocator); 
        var i: usize = self.symbols.items.len;
        while (i > sym_count) {
            const child = self.symbols.pop();
            symbols.append(child) catch unreachable;
            i -= 1;
        }

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end),
            .aside_symbols = symbols
        }) catch unreachable;
        
        return node;
    }

    fn parseTypeAlias(self: *Parser) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        const name = self.expectIdentifier();
        self.advance();
        self.expectSymbol(lexer.TokenSymbol.Equal);
        self.advance();
        const value = self.expectIdentifier();
        const end = self.getCurrent().?.end;
        self.advance();

        // Generate Node
        const node = Node.gen(NodeData {
            .Type = TypeNode {
                .name = name,
                .value = value
            }
        });

        // Generate symbol
        const sym = symbol.Symbol.gen(symbol.SymbolData {
            .TypeAlias = symbol.TypeAliasSymbol {
                .name = name,
                .value = value
            }
        }, node.id);
        self.symbols.append(sym) catch unreachable;

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end),
            .symbol_def = sym.id
        }) catch unreachable;

        return node;
    }

    fn handleKeyword(self: *Parser, keyword: lexer.TokenKeyword) Node {
        const start = self.getCurrent().?.start;
        switch (keyword) {
            .Fn => return self.parseFunctionDefinition(false, false, start),
            .Extern => {
                self.advance();
                self.expectExactKeyword(lexer.TokenKeyword.Fn);
                return self.parseFunctionDefinition(true, false, start);
            },
            .Use => return self.parseUse(),
            .Return => return self.parseReturn(),
            .Const => return self.parseVariableDefinition(true, start),
            .Var => return self.parseVariableDefinition(false, start),
            .Not => return self.parseExpr(),
            .If => return self.parseIfStatement(),
            .While => return self.parseWhileLoop(),
            .Continue => return self.parseContinue(),
            .Break => return self.parseBreak(),
            .Match => return self.parseMatch(),
            .Class => return self.parseClass(start, false),
            .New => return self.parseFunctionDefinition(false, true, start),
            .Type => return self.parseTypeAlias(),
            .Extend => return self.parseExtend(),
            .Sealed => {
                self.advance();
                self.expectExactKeyword(lexer.TokenKeyword.Class);
                return self.parseClass(start, true);
            },
            else => {
                const current = self.getCurrent().?;
                current.errorMessage("Unexpected token '{full}'!", .{current.data});
            }
        }
    }

    fn parseLabel(self: *Parser, id: []const u8) Node {
        const start = self.getCurrent().?.start;
        self.advance();
        self.expectSymbol(lexer.TokenSymbol.Colon);
        const end = self.getCurrent().?.end;
        self.advance();

        // Generate node
        const node = Node.gen(NodeData {
            .Label = LabelNode {
                .label = id
            }
        });

        // Generate node informations
        self.infos.append(NodeInfo {
            .node_id = node.id,
            .position = position.Positioned(void).init(void {}, start, end)
        }) catch unreachable;

        return node;
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
            .Symbol => |sym| {
                switch (sym) {
                    .LeftParenthesis, .Plus, .Dash => return self.parseExpr(),
                    else => {
                        current.errorMessage("Unexpected token '{full}'!", .{current.data});
                    }
                }
            },
            .Label => |id| return self.parseLabel(id),
        }
    }

    pub fn parse(self: *Parser) struct { NodeList, NodeInfos, symbol.SymbolList } {
        var nodes = NodeList.init(self.allocator);

        while (self.getCurrent() != null) {
            nodes.append(self.parseCurrent()) catch unreachable;
            self.expectEOS();
            self.advance();
        }

        return . {
            nodes,
            self.infos,
            self.symbols,
        };
    }
};