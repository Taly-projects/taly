const std = @import("std");
const parser = @import("parser.zig");

pub const ValueNodeTag = enum {
    String,
    Int,
    Float,
};

pub const ValueNode = union(ValueNodeTag) {
    String: []const u8,
    Int: []const u8,
    Float: []const u8,

    pub fn writeC(self: *const ValueNode, writer: anytype, tabs: usize) anyerror!bool {
        switch (self.*) {
            .String => |str| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                try std.fmt.format(writer, "\"{s}\"", .{str});
                return true;
            },
            .Int => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                try std.fmt.format(writer, "{s}", .{num});
                return true;
            },
            .Float => |num| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                try std.fmt.format(writer, "{s}", .{num});
                return true;
            }
        }
    }

};

pub const FunctionDefinitionParameter = struct {
    name: []const u8,
    data_type: []const u8,

    pub fn writeC(self: *const FunctionDefinitionParameter, writer: anytype) anyerror!void {
        try std.fmt.format(writer, "{s} {s}", .{ self.data_type, self.name });
    }
    
};

pub const FunctionDefinitionParameters = std.ArrayList(FunctionDefinitionParameter);


pub const FunctionHeader = struct {
    name: []const u8,
    parameters: FunctionDefinitionParameters,
    return_type: []const u8,

    pub fn writeC(self: *const FunctionHeader, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s} {s}(", .{self.return_type, self.name});
        i = 0;
        for (self.parameters.items) |param| {
            if (i != 0) try writer.writeAll(", ");
            _ = try param.writeC(writer);
            i += 1;
        }
        try writer.writeAll(")");
        return true;
    }
    
};

pub const FunctionSource = struct {
    name: []const u8,
    parameters: FunctionDefinitionParameters,
    return_type: []const u8,
    body: NodeList,

    pub fn writeC(self: *const FunctionSource, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s} {s}(", .{self.return_type, self.name});
        i = 0;
        for (self.parameters.items) |param| {
            if (i != 0) try writer.writeAll(", ");
            _ = try param.writeC(writer);
            i += 1;
        }
        try writer.writeAll(") {");
        i = 0;
        for (self.body.items) |node|  {
            try writer.writeAll("\n");
            // Add tabs
            var j: usize = 0;
            while (j < tabs) : (j += 1) try writer.writeAll("\t");
            if (try node.writeC(writer, tabs + 1)) {
                try writer.writeAll(";");
            }
            i += 1;
        }
        if (self.body.items.len != 0) {
            try writer.writeAll("\n");
            i = 0;
            while (i < tabs) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("}");
        return false;
    }
    
};

pub const FunctionCallNode = struct {
    name: []const u8,
    parameters: NodeList,

    pub fn writeC(self: *const FunctionCallNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s}(", .{self.name});
        i = 0;
        for (self.parameters.items) |param| {
            if (i != 0) try writer.writeAll(", ");
            _ = try param.writeC(writer, 0);
            i += 1;
        }
        try writer.writeAll(")");

        return true;
    }

};

pub const IncludeNode = struct {
    std: bool,
    path: []const u8,

    pub fn writeC(self: *const IncludeNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "#include ", .{});

        if (self.std) {
            try std.fmt.format(writer, "<{s}.h>", .{self.path});
        } else {
            try std.fmt.format(writer, "\"{s}.h\"", .{self.path});
        }

        return false;
    }

};

pub const ReturnNode = struct {
    value: ?*Node,

    pub fn writeC(self: *const ReturnNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "return ", .{});

        if (self.value) |value| {
            _ = try value.writeC(writer, 0);
        }

        return true;
    }
    
};

pub const VariableDefinitionNode = struct {
    constant: bool,
    name: []const u8,
    data_type: []const u8,
    value: ?*Node,

    pub fn writeC(self: *const VariableDefinitionNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        if (self.constant and !std.mem.startsWith(u8, self.data_type, "const ")) {
            try writer.writeAll("const ");
        }

        try std.fmt.format(writer, "{s} {s}", .{self.data_type, self.name});

        if (self.value) |value| {
            try writer.writeAll(" = ");
            _ = try value.writeC(writer, 0);
        }

        return true;
    }

};

pub const VariableCallNode = struct {
    name: []const u8,

    pub fn writeC(self: *const VariableCallNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s}", .{self.name});

        return true;
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
    PointerAccess,
};

pub const BinaryOperationNode = struct {
    lhs: *Node,
    operator: Operator,
    rhs: *Node,

    pub fn writeC(self: *const BinaryOperationNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("(");
        _ = try self.lhs.writeC(writer, 0);
        
        switch (self.operator) {
            .Add => {
                try writer.writeAll(" + ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Subtract => {
                try writer.writeAll(" - ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Multiply => {
                try writer.writeAll(" * ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Divide => {
                try writer.writeAll(" / ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Assignment => {
                try writer.writeAll(" = ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Greater => {
                try writer.writeAll(" > ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .GreaterOrEqual => {
                try writer.writeAll(" >= ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Less => {
                try writer.writeAll(" < ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .LessOrEqual => {
                try writer.writeAll(" <= ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Equal => {
                try writer.writeAll(" == ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .NotEqual => {
                try writer.writeAll(" != ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .And => {
                try writer.writeAll(" && ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Or => {
                try writer.writeAll(" || ");
                _ = try self.rhs.writeC(writer, 0);
            },
            .Access => {
                try writer.writeAll(".");
                _ = try self.rhs.writeC(writer, 0);
            },
            .PointerAccess => {
                try writer.writeAll("->");
                _ = try self.rhs.writeC(writer, 0);
            },
            else => unreachable,
        }
        try writer.writeAll(")");

        return true;
    }
};

pub const UnaryOperationNode = struct {
    operator: Operator,
    value: *Node,

    pub fn writeC(self: *const UnaryOperationNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("(");
        
        switch (self.operator) {
            .Add => {
                try writer.writeAll("+");
                _ = try self.value.writeC(writer, 0);
            },
            .Subtract => {
                try writer.writeAll("-");
                _ = try self.value.writeC(writer, 0);
            },
            .Not => {
                try writer.writeAll("!");
                _ = try self.value.writeC(writer, 0);
            },
            else => unreachable,
        }
        try writer.writeAll(")");

        return true;
    }
};

pub const IfBranch = struct {
    condition: *Node,
    body: NodeList,
};
pub const IfBranches = std.ArrayList(IfBranch);

pub const IfNode = struct {
    if_branch: IfBranch,
    elif_branches: IfBranches,
    else_body: NodeList,

    pub fn writeC(self: *const IfNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("if (");
        _ = try self.if_branch.condition.writeC(writer, 0);
        try writer.writeAll(") {\n");
        
        for (self.if_branch.body.items) |node| {
            if (try node.writeC(writer, tabs + 1)) {
                try writer.writeAll(";");
            }
            try writer.writeAll("\n");
        }

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        try writer.writeAll("}");
        
        for (self.elif_branches.items) |branch| {
            try writer.writeAll(" else if (");
            _ = try branch.condition.writeC(writer, 0);
            try writer.writeAll(") {\n");
            
            for (branch.body.items) |node| {
                if (try node.writeC(writer, tabs + 1)) {
                    try writer.writeAll(";");
                }
                try writer.writeAll("\n");
            }

            // Add tabs
            i = 0;
            while (i < tabs) : (i += 1) try writer.writeAll("\t");
            try writer.writeAll("}");
        }

        if (self.else_body.items.len != 0) {
            try writer.writeAll(" else {\n");
            
            for (self.else_body.items) |node| {
                if (try node.writeC(writer, tabs + 1)) {
                    try writer.writeAll(";");
                }
                try writer.writeAll("\n");
            }

            // Add tabs
            i = 0;
            while (i < tabs) : (i += 1) try writer.writeAll("\t");
            try writer.writeAll("}");
        }
        try writer.writeAll("\n");

        return false;
    }
};

pub const WhileNode = struct {
    condition: *Node,
    body: NodeList,

    pub fn writeC(self: *const WhileNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("while (");
        _ = try self.condition.writeC(writer, 0);
        try writer.writeAll(") {\n");
        
        for (self.body.items) |node| {
            if (try node.writeC(writer, tabs + 1)) {
                try writer.writeAll(";");
            }
            try writer.writeAll("\n");
        }
        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");
        try writer.writeAll("}\n");

        return false;
    }
};

pub const LabelNode = struct {
    label: []const u8,

    pub fn writeC(self: *const LabelNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s}: ", .{self.label});

        return true;
    }
};

pub const ContinueNode = struct {
    label: ?[]const u8,

    pub fn writeC(self: *const ContinueNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("continue");

        if (self.label) |label| {
            try std.fmt.format(writer, " {s}", .{label});
        }

        return true;
    }
};

pub const BreakNode = struct {
    label: ?[]const u8,

    pub fn writeC(self: *const BreakNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("break");

        if (self.label) |label| {
            try std.fmt.format(writer, " {s}", .{label});
        }

        return true;
    }
};

pub const StructField = struct {
    data_type: []const u8,
    name: []const u8,

    pub fn writeC(self: *const StructField, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s} {s}", .{self.data_type, self.name});
        
        return true;
    }
};
pub const StructFields = std.ArrayList(StructField);

pub const StructNode = struct {
    name: []const u8,
    fields: StructFields,

    pub fn writeC(self: *const StructNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "typedef struct {s} {{", .{self.name});

        for (self.fields.items) |field| {
            try writer.writeAll("\n");
            if (try field.writeC(writer, tabs + 1)) {
                try writer.writeAll(";");
            }
        }
        if (self.fields.items.len != 0) {
            try writer.writeAll("\n");

            // Add tabs
            i = 0;
            while (i < tabs) : (i += 1) try writer.writeAll("\t");
        }
        try std.fmt.format(writer, "}} {s}", .{self.name});

        return true;
    }
};

pub const TypedefNode = struct {
    name: []const u8,
    value: []const u8,

    pub fn writeC(self: *const TypedefNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "typedef {s} {s}", .{self.value, self.name});

        return true;
    }
};

pub const CI_PureCNode = struct {
    code: []const u8,

    pub fn writeC(self: *const CI_PureCNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s}", .{self.code});

        return false;
    }
};


pub const CI_PreCNode = struct {
    code: []const u8,
    node: *Node,

    pub fn writeC(self: *const CI_PreCNode, writer: anytype, tabs: usize) anyerror!bool {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "{s}", .{self.code});
        return try self.node.writeC(writer, 0);
    }
};

pub const NodeTag = enum {
    Value,
    FunctionHeader,
    FunctionSource,
    FunctionCall,
    Include,
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
    Struct,
    Typedef,
    CI_PureC,
    CI_PreC,
};

pub const Node = union(NodeTag) {
    Value: ValueNode,
    FunctionHeader: FunctionHeader,
    FunctionSource: FunctionSource,
    FunctionCall: FunctionCallNode,
    Include: IncludeNode,
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
    Struct: StructNode,
    Typedef: TypedefNode,
    CI_PureC: CI_PureCNode,
    CI_PreC: CI_PreCNode,

    pub fn writeC(self: *const Node, writer: anytype, tabs: usize) anyerror!bool {
        switch (self.*) {
            .Value => |node| return node.writeC(writer, tabs),
            .FunctionHeader => |node| return node.writeC(writer, tabs),
            .FunctionSource => |node| return node.writeC(writer, tabs),
            .FunctionCall => |node| return node.writeC(writer, tabs),
            .Include => |node| return node.writeC(writer, tabs),
            .Return => |node| return node.writeC(writer, tabs),
            .VariableDefinition => |node| return node.writeC(writer, tabs),
            .VariableCall => |node| return node.writeC(writer, tabs),
            .BinaryOperation => |node| return node.writeC(writer, tabs),
            .UnaryOperation => |node| return node.writeC(writer, tabs),
            .If => |node| return node.writeC(writer, tabs),
            .While => |node| return node.writeC(writer, tabs),
            .Label => |node| return node.writeC(writer, tabs),
            .Continue => |node| return node.writeC(writer, tabs),
            .Break => |node| return node.writeC(writer, tabs),
            .Struct => |node| return node.writeC(writer, tabs),
            .Typedef => |node| return node.writeC(writer, tabs),
            .CI_PureC => |node| return node.writeC(writer, tabs),
            .CI_PreC => |node| return node.writeC(writer, tabs),
        }
    }

};

pub const NodeList = std.ArrayList(Node);

pub const File = struct {
    name: []const u8,
    source: NodeList,
    header: NodeList,

    pub fn init(name: []const u8, allocator: std.mem.Allocator) File {
        return . {
            .name = name,
            .source = NodeList.init(allocator),
            .header = NodeList.init(allocator)
        };
    }

    pub fn append(self: *File, other: *const File) void {
        const final_name = if (std.mem.eql(u8, self.name, other.name)) self.name
        else if (std.mem.eql(u8, other.name, "_")) self.name
        else if (std.mem.eql(u8, self.name, "_")) other.name
        else @panic("File name not matching!");

        self.name = final_name;
        self.source.appendSlice(other.source.items) catch unreachable;
        self.header.appendSlice(other.header.items) catch unreachable;
    }

};

pub const FileList = std.ArrayList(File);

pub const Project = struct {
    allocator: std.mem.Allocator,
    files: FileList,

    pub fn init(allocator: std.mem.Allocator) Project {
        return . {
            .allocator = allocator,
            .files = FileList.init(allocator)
        };
    }

    pub fn getFile(self: *Project, name: []const u8) *File {
        for (self.files.items) |*file| {
            if (std.mem.eql(u8, file.name, name)) {
                return file;
            }
        }

        self.files.append(File {
            .name = name,
            .source = NodeList.init(self.allocator),
            .header = NodeList.init(self.allocator),
        }) catch unreachable;

        return &self.files.items[self.files.items.len - 1];
    }
};

pub const Translator = struct {
    allocator: std.mem.Allocator,
    ast: parser.NodeList,
    infos: parser.NodeInfos,
    symbols: parser.SymbolList,
    index: usize = 0,
    header: NodeList,

    pub fn init(ast: parser.NodeList, infos: parser.NodeInfos, symbols: parser.SymbolList, allocator: std.mem.Allocator) Translator {
        return . {
            .allocator = allocator,
            .ast = ast,
            .infos = infos,
            .symbols = symbols,
            .header = NodeList.init(allocator),
        };
    }

    fn getCurrent(self: *const Translator) ?parser.Node {
        if (self.index >= self.ast.items.len) return null;
        return self.ast.items[self.index];
    }

    fn advance(self: *Translator) void {
        self.index += 1;
    }

    fn getInfo(self: *const Translator, id: usize) ?*parser.NodeInfo {
        for (self.infos.items) |*info| {
            if (info.node_id == id) return info;
        }
        return null;
    }

    fn getSymbol(self: *const Translator, id: usize) ?*parser.Symbol {
        for (self.symbols.items) |*sym| {
            if (sym.getSymbol(id)) |sym2| return sym2;
        }

        return null;
    }

    fn translateType(self: *Translator, data_type: []const u8) []const u8 {
        _ = self;

        if (std.mem.eql(u8, data_type, "c_int")) return "int"
        else if (std.mem.eql(u8, data_type, "c_float")) return "float"
        else if (std.mem.eql(u8, data_type, "c_string")) return "const char*";

        return data_type;
    }

    fn translateValueNode(self: *Translator, node: parser.Node) Node {
        _ = self;
        switch (node.data.Value) {
            .String => |str| return Node { .Value = . { .String = str } },
            .Int => |num| return Node { .Value = . { .Int = num } },
            .Float => |num| return Node { .Value = . { .Float = num } },
            .Bool => |b| return Node { .Value = . { .Int = if (b) "1" else "0" } },
        }
    }

    fn translateFunctionDefinition(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const function_def = node.data.FunctionDefinition;

        // External functions nothing to do (only used to tell the compiler a function exists)..
        if (function_def.external) return nodes;

        // Rename the function (if necessary)
        const info = self.getInfo(node.id).?;
        const name = if (info.renamed) |renamed| renamed else function_def.name;

        // Translate parameters
        var parameters = FunctionDefinitionParameters.init(self.allocator);
        for (function_def.parameters.items) |param| {
            parameters.append(FunctionDefinitionParameter {
                .name = param.name,
                .data_type = self.translateType(param.data_type)
            }) catch unreachable;
        }

        // Generate header (if not main)
        if (!std.mem.eql(u8, function_def.name, "main")) {
            self.header.append(Node {
                .FunctionHeader = .{
                    .name = name,
                    .parameters = parameters,
                    .return_type = self.translateType(function_def.return_type orelse "void")
                }
            }) catch unreachable; 
        }

        // Translate body
        var body = NodeList.init(self.allocator);
        for (function_def.body.items) |child| {
            body.appendSlice(self.translateNode(child).items) catch unreachable;
        }

        // Create translated node
        nodes.append(Node {
            .FunctionSource = .{
                .name = name,
                .parameters = parameters,
                .return_type = self.translateType(function_def.return_type orelse "void"),
                .body = body
            }
        }) catch unreachable; 

        return nodes;
    }

    fn translateFunctionCall(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const function_call = node.data.FunctionCall;

        const info = self.getInfo(node.id).?;
        const sym = self.getSymbol(info.symbol_call.?).?;

        const sym_node_info = self.getInfo(sym.node_id).?;
        const name = sym_node_info.renamed orelse node.data.FunctionCall.name;

        // Translate Parameters
        var parameters = NodeList.init(self.allocator);
        for (function_call.parameters.items) |param| {
            var res = self.translateNode(param);
            parameters.append(res.pop()) catch unreachable;
            nodes.appendSlice(res.items) catch unreachable;
        }

        // Create translated node
        nodes.append(Node {
            .FunctionCall = . {
                .name = name,
                .parameters = parameters
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateUse(self: *Translator, node: parser.Node) void {
        const use = node.data.Use;

        if (std.mem.startsWith(u8, use.path, "std-")) {
            self.header.append(Node {
                .Include = .{
                    .std = true,
                    .path = use.path[4..]
                }
            }) catch unreachable;
        } else if (std.mem.startsWith(u8, use.path, "c-")) {
            self.header.append(Node {
                .Include = .{
                    .std = false,
                    .path = use.path[2..]
                }
            }) catch unreachable;
        } else {
            self.header.append(Node {
                .Include = .{
                    .std = false,
                    .path = use.path
                }
            }) catch unreachable;
        }
    }

    fn translateReturn(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const return_node = node.data.Return;

        // Translate value (if present)
        var new_value: ?*Node = null;
        if (return_node.value) |value| {
            new_value = self.allocator.create(Node) catch unreachable;
            var res = self.translateNode(value.*);
            new_value.?.* = res.pop();
            nodes.appendSlice(res.items) catch unreachable;
        }

        // Create translated node
        nodes.append(Node {
            .Return = . {
                .value = new_value
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateVariableDefinition(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const variable_def = node.data.VariableDefinition;
        
        // Translate type
        const new_data_type = self.translateType(variable_def.data_type);

        // Translate value (if present)
        var new_value: ?*Node = null;
        if (variable_def.value) |value| {
            new_value = self.allocator.create(Node) catch unreachable;
            var res = self.translateNode(value.*);
            new_value.?.* = res.pop();
            nodes.appendSlice(res.items) catch unreachable;
        }

        // Create translated node
        nodes.append(Node {
            .VariableDefinition = .{
                .constant = variable_def.constant,
                .name = variable_def.name,
                .data_type = new_data_type,
                .value = new_value
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateVariableCall(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const variable_call = node.data.VariableCall;

        // Create translated node
        nodes.append(Node {
            .VariableCall = .{ 
                .name = variable_call.name
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateBinaryOperation(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const bin_op = node.data.BinaryOperation;

        // Translate LHS
        var lhs_res = self.translateNode(bin_op.lhs.*);
        var lhs_node = self.allocator.create(Node) catch unreachable;
        lhs_node.* = lhs_res.pop();
        nodes.appendSlice(lhs_res.items) catch unreachable;

        // Translate RHS 
        var rhs_res = self.translateNode(bin_op.rhs.*);
        var rhs_node = self.allocator.create(Node) catch unreachable;
        rhs_node.* = rhs_res.pop();
        nodes.appendSlice(rhs_res.items) catch unreachable;

        // Translate Operator
        var operator: Operator = undefined;
        switch (bin_op.operator) {
            .Add => operator = .Add,
            .Subtract => operator = .Subtract,
            .Multiply => operator = .Multiply,
            .Divide => operator = .Divide,
            .Assignment => operator = .Assignment,
            .Greater => operator = .Greater,
            .GreaterOrEqual => operator = .GreaterOrEqual,
            .Less => operator = .Less,
            .LessOrEqual => operator = .LessOrEqual,
            .Equal => operator = .Equal,
            .NotEqual => operator = .NotEqual,
            .And => operator = .And,
            .Or => operator = .Or,
            .Access => {
                const lhs_info = self.getInfo(node.data.BinaryOperation.lhs.id).?;
                const lhs_sym = self.getSymbol(lhs_info.symbol_call.?).?;
                
                if (lhs_sym.data == parser.SymbolTag.Variable) {
                    const rhs_info = self.getInfo(node.data.BinaryOperation.rhs.id).?;
                    const rhs_sym = self.getSymbol(rhs_info.symbol_call.?).?;

                    if (rhs_sym.data == parser.SymbolTag.Function) {
                        var parameters = NodeList.init(self.allocator);
                        parameters.append(Node {
                            .CI_PreC = CI_PreCNode {
                                .code = "&",
                                .node = lhs_node
                            }
                        }) catch unreachable;
                        parameters.appendSlice(rhs_node.FunctionCall.parameters.items) catch unreachable;
                        rhs_node.FunctionCall.parameters = parameters;
                        nodes.append(rhs_node.*) catch unreachable;
                        return nodes;   
                    } else {
                        operator = .PointerAccess;
                    }
                } else {
                    const rhs_info = self.getInfo(node.data.BinaryOperation.rhs.id).?;
                    const rhs_sym = self.getSymbol(rhs_info.symbol_call.?).?;

                    if (rhs_sym.data == parser.SymbolTag.Function) {
                        nodes.append(rhs_node.*) catch unreachable;
                        return nodes;   
                    } else {
                        operator = .Access;
                    }
                }

            },
            else => unreachable
        }

        // Create translated node
        nodes.append(Node {
            .BinaryOperation = BinaryOperationNode {
                .lhs = lhs_node,
                .operator = operator,
                .rhs = rhs_node,
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateUnaryOperation(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const un_op = node.data.UnaryOperation;

        // Translate value
        var res = self.translateNode(un_op.value.*);
        var value_node = self.allocator.create(Node) catch unreachable;
        value_node.* = res.pop();
        nodes.appendSlice(res.items) catch unreachable;

        // Translate operator
        var operator: Operator = undefined;
        switch (un_op.operator) {
            .Add => operator = .Add,
            .Subtract => operator = .Subtract,
            .Not => operator = .Not,
            else => unreachable
        }

        // Create translated node
        nodes.append(Node {
            .UnaryOperation = UnaryOperationNode {
                .operator = operator,
                .value = value_node,
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateIfStatement(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const if_node = node.data.If;

        var condition = self.allocator.create(Node) catch unreachable;
        var node_res = self.translateNode(if_node.if_branch.condition.*);
        condition.* = node_res.pop();
        nodes.appendSlice(node_res.items) catch unreachable;

        var body = NodeList.init(self.allocator);
        for (if_node.if_branch.body.items) |child| {
            node_res = self.translateNode(child);
            body.appendSlice(node_res.items) catch unreachable;
        }

        var elif_branches = IfBranches.init(self.allocator);
        for (if_node.elif_branches.items) |branch| {
            var elif_condition = self.allocator.create(Node) catch unreachable;
            node_res = self.translateNode(branch.condition.*);
            elif_condition.* = node_res.pop();
            nodes.appendSlice(node_res.items) catch unreachable;

            var elif_body = NodeList.init(self.allocator);
            for (branch.body.items) |child| {
                node_res = self.translateNode(child);
                elif_body.appendSlice(node_res.items) catch unreachable;
            }

            elif_branches.append(IfBranch {
                .condition = elif_condition,
                .body = elif_body
            }) catch unreachable;
        }

        var else_body = NodeList.init(self.allocator);
        for (if_node.else_body.items) |child| {
            node_res = self.translateNode(child);
            else_body.appendSlice(node_res.items) catch unreachable;
        }

        nodes.append(Node {
            .If = IfNode {
                .if_branch = IfBranch {
                    .condition = condition,
                    .body = body
                },
                .elif_branches = elif_branches,
                .else_body = else_body
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateWhileLoop(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const while_node = node.data.While;

        var condition = self.allocator.create(Node) catch unreachable;
        var node_res = self.translateNode(while_node.condition.*);
        condition.* = node_res.pop();
        nodes.appendSlice(node_res.items) catch unreachable;

        var body = NodeList.init(self.allocator);
        for (while_node.body.items) |child| {
            node_res = self.translateNode(child);
            body.appendSlice(node_res.items) catch unreachable;
        }

        nodes.append(Node {
            .While = WhileNode {
                .condition = condition,
                .body = body
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateMatchStatement(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const match_node = node.data.Match;

        var lhs = self.allocator.create(Node) catch unreachable;
        var res = self.translateNode(match_node.condition.*);
        lhs.* = res.pop();
        nodes.appendSlice(res.items) catch unreachable;

        var if_branch: ?IfBranch = null;
        var branches = IfBranches.init(self.allocator);

        for (match_node.branches.items) |branch| {
            var rhs = self.allocator.create(Node) catch unreachable;
            res = self.translateNode(branch.condition.*);
            rhs.* = res.pop();
            nodes.appendSlice(res.items) catch unreachable;

            var condition = self.allocator.create(Node) catch unreachable;
            condition.* = Node {
                .BinaryOperation = BinaryOperationNode {
                    .lhs = lhs,
                    .operator = Operator.Equal,
                    .rhs = rhs
                }
            };

            var body = NodeList.init(self.allocator);
            for (branch.body.items) |child| {
                body.appendSlice(self.translateNode(child).items) catch unreachable;
            }

            const new_branch = IfBranch {
                .condition = condition,
                .body = body
            };

            if (if_branch == null) {
                if_branch = new_branch;
            } else {
                branches.append(new_branch) catch unreachable;
            }
        }

        var else_body = NodeList.init(self.allocator);
        for (match_node.else_body.items) |child| {
            else_body.appendSlice(self.translateNode(child).items) catch unreachable;
        }

        nodes.append(Node {
            .If = IfNode {
                .if_branch = if_branch.?,
                .elif_branches = branches,
                .else_body = else_body,
            }
        }) catch unreachable;

        return nodes;
    }

    fn translateLabel(self: *Translator, node: parser.Node) Node {
        _ = self;

        const label = node.data.Label;

        return Node {
            .Label = LabelNode {
                .label = label.label
            }
        };
    }

    fn translateContinue(self: *Translator, node: parser.Node) Node {
        _ = self;

        const ctn = node.data.Continue;

        return Node {
            .Continue = ContinueNode {
                .label = ctn.label
            }
        };
    }

    fn translateBreak(self: *Translator, node: parser.Node) Node {
        _ = self;

        const brk = node.data.Break;

        return Node {
            .Break = BreakNode {
                .label = brk.label
            }
        };
    }

    fn translateClass(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const class = node.data.Class;

        var fields = StructFields.init(self.allocator);
        var methods = parser.NodeList.init(self.allocator);
        
        for (class.body.items) |child| {
            if (child.data == parser.NodeTag.VariableDefinition) {
                fields.append(StructField {
                    .name = child.data.VariableDefinition.name,
                    .data_type = self.translateType(child.data.VariableDefinition.data_type),
                }) catch unreachable;
            } else if (child.data == parser.NodeTag.FunctionDefinition) {
                methods.append(child) catch unreachable;
            } else {
                @panic("Unexpected node in class!");
            }
        }

        self.header.append(Node {
            .Struct = StructNode {
                .name = class.name,
                .fields = fields
            }
        }) catch unreachable;

        for (methods.items) |method| {
            nodes.appendSlice(self.translateNode(method).items) catch unreachable;
        }

        return nodes;
    }

    fn translateTypeAlias(self: *Translator, node: parser.Node) void {
        self.header.append(Node {
            .Typedef = TypedefNode {
                .name = node.data.Type.name,
                .value = node.data.Type.value
            }
        }) catch unreachable;
    }

    fn translateCIPureC(self: *Translator, node: parser.Node) Node {
        _ = self;

        return Node {
            .CI_PureC = CI_PureCNode {
                .code = node.data.CI_PureC.code
            }
        };
    }

    fn translateExtend(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);

        const extend = node.data.ExtendStatement;

        var methods = parser.NodeList.init(self.allocator);
        
        for (extend.body.items) |child| {
            if (child.data == parser.NodeTag.FunctionDefinition) {
                methods.append(child) catch unreachable;
            } else {
                @panic("Unexpected node in class!");
            }
        }

        for (methods.items) |method| {
            nodes.appendSlice(self.translateNode(method).items) catch unreachable;
        }

        return nodes;
    }

    fn translateNode(self: *Translator, node: parser.Node) NodeList {
        var nodes = NodeList.init(self.allocator);
        switch (node.data) {
            .Value => nodes.append(self.translateValueNode(node)) catch unreachable,
            .FunctionDefinition => nodes.appendSlice(self.translateFunctionDefinition(node).items) catch unreachable,
            .FunctionCall => nodes.appendSlice(self.translateFunctionCall(node).items) catch unreachable,
            .Use => self.translateUse(node),
            .Return => nodes.appendSlice(self.translateReturn(node).items) catch unreachable,
            .VariableDefinition => nodes.appendSlice(self.translateVariableDefinition(node).items) catch unreachable,
            .VariableCall => nodes.appendSlice(self.translateVariableCall(node).items) catch unreachable,
            .BinaryOperation => nodes.appendSlice(self.translateBinaryOperation(node).items) catch unreachable,
            .UnaryOperation => nodes.appendSlice(self.translateUnaryOperation(node).items) catch unreachable,
            .If => nodes.appendSlice(self.translateIfStatement(node).items) catch unreachable,
            .While => nodes.appendSlice(self.translateWhileLoop(node).items) catch unreachable,
            .Label => nodes.append(self.translateLabel(node)) catch unreachable,
            .Continue => nodes.append(self.translateContinue(node)) catch unreachable,
            .Break => nodes.append(self.translateBreak(node)) catch unreachable,
            .Match => nodes.appendSlice(self.translateMatchStatement(node).items) catch unreachable,
            .Class => nodes.appendSlice(self.translateClass(node).items) catch unreachable,
            .Type => self.translateTypeAlias(node),
            .ExtendStatement => nodes.appendSlice(self.translateExtend(node).items) catch unreachable,
            .CI_PureC => nodes.append(self.translateCIPureC(node)) catch unreachable,
        }
        return nodes;
    }

    pub fn translate(self: *Translator, name: []const u8) File {
        var file = File.init(name, self.allocator);

        while (self.getCurrent()) |current| {
            const nodes = self.translateNode(current);
            file.source.appendSlice(nodes.items) catch unreachable;

            // const file = if (std.mem.eql(u8, res.name, "_")) project.getFile("main")
            // else project.getFile(res.name);
            // file.append(&res);
            self.advance();
        }

        file.header.appendSlice(self.header.items) catch unreachable;

        // Generate links between .h and .c
        if (file.header.items.len != 0 and file.source.items.len != 0) {
            var new_source = NodeList.init(self.allocator);
            new_source.append(Node {
                .Include = . {
                    .std = false,
                    .path = file.name
                }
            }) catch unreachable;
            new_source.appendSlice(file.source.items) catch unreachable;
            file.source = new_source;
        }

        return file;
    }

};