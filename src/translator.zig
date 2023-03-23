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
            }
        }
        try writer.writeAll(")");

        return true;
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
    index: usize = 0,

    pub fn init(ast: parser.NodeList, allocator: std.mem.Allocator) Translator {
        return . {
            .allocator = allocator,
            .ast = ast
        };
    }

    fn getCurrent(self: *const Translator) ?parser.Node {
        if (self.index >= self.ast.items.len) return null;
        return self.ast.items[self.index];
    }

    fn advance(self: *Translator) void {
        self.index += 1;
    }

    fn translateType(self: *Translator, data_type: []const u8) []const u8 {
        _ = self;

        if (std.mem.eql(u8, data_type, "c_int")) return "int"
        else if (std.mem.eql(u8, data_type, "c_float")) return "float"
        else if (std.mem.eql(u8, data_type, "c_string")) return "const char*";

        return data_type;
    }

    fn translateValueNode(self: *Translator, value: parser.ValueNode) Node {
        _ = self;
        switch (value) {
            .String => |str| return Node { .Value = . { .String = str } },
            .Int => |num| return Node { .Value = . { .Int = num } },
            .Float => |num| return Node { .Value = . { .Float = num } },
        }
    }

    fn translateFunctionDefinition(self: *Translator, function_def: parser.FunctionDefinitionNode) File {
        var file = File.init("_", self.allocator);

        if (function_def.external) return file;

        var parameters = FunctionDefinitionParameters.init(self.allocator);
        for (function_def.parameters.items) |param| {
            parameters.append(FunctionDefinitionParameter {
                .name = param.name,
                .data_type = param.data_type
            }) catch unreachable;
        }

        if (!std.mem.eql(u8, function_def.name, "main")) {
            file.header.append(Node {
                .FunctionHeader = .{
                    .name = function_def.name,
                    .parameters = parameters,
                    .return_type = self.translateType(function_def.return_type orelse "void")
                }
            }) catch unreachable; 
        }

        var body = NodeList.init(self.allocator);
        for (function_def.body.items) |node| {
            const res = self.translateNode(node);
            body.appendSlice(res.source.items) catch unreachable;
            file.header.appendSlice(res.header.items) catch unreachable;
        }

        file.source.append(Node {
            .FunctionSource = .{
                .name = function_def.name,
                .parameters = parameters,
                .return_type = self.translateType(function_def.return_type orelse "void"),
                .body = body
            }
        }) catch unreachable; 

        return file;
    }

    fn translateFunctionCall(self: *Translator, function_call: parser.FunctionCallNode) Node {
        var parameters = NodeList.init(self.allocator);
        for (function_call.parameters.items) |param| {
            // Header ignore (there should be nothing in it)
            parameters.appendSlice(self.translateNode(param).source.items) catch unreachable;
        }

        return Node {
            .FunctionCall = . {
                .name = function_call.name,
                .parameters = parameters
            }
        };
    }

    fn translateUse(self: *Translator, use: parser.UseNode) ?Node {
        _ = self;
        if (std.mem.startsWith(u8, use.path, "std-")) {
            return Node {
                .Include = .{
                    .std = true,
                    .path = use.path[4..]
                }
            };
        } else if (std.mem.startsWith(u8, use.path, "c-")) {
            return Node {
                .Include = .{
                    .std = false,
                    .path = use.path[2..]
                }
            };
        } 

        return null;
    }

    fn translateReturn(self: *Translator, return_node: parser.ReturnNode) File {
        var res = File.init("_", self.allocator);
        var new_value: ?*Node = null;
        if (return_node.value) |value| {
            new_value = self.allocator.create(Node) catch unreachable;
            var node_res = self.translateNode(value.*);
            new_value.?.* = node_res.source.pop();
            res.append(&node_res);
        }

        res.source.append(Node {
            .Return = . {
                .value = new_value
            }
        }) catch unreachable;

        return res;
    }

    fn translateVariableDefinition(self: *Translator, node: parser.VariableDefinitionNode) File {
        var res = File.init("_", self.allocator);
        
        const new_data_type = self.translateType(node.data_type);

        var new_value: ?*Node = null;
        if (node.value) |value| {
            new_value = self.allocator.create(Node) catch unreachable;
            var value_res = self.translateNode(value.*);
            new_value.?.* = value_res.source.pop();
            res.append(&value_res);
        }

        res.source.append(Node {
            .VariableDefinition = .{
                .constant = node.constant,
                .name = node.name,
                .data_type = new_data_type,
                .value = new_value
            }
        }) catch unreachable;

        return res;
    }

    fn translateVariableCall(self: *Translator, node: parser.VariableCallNode) File {
        var res = File.init("_", self.allocator);

        res.source.append(Node {
            .VariableCall = .{ 
                .name = node.name
            }
        }) catch unreachable;

        return res;
    }

    fn translateBinaryOperation(self: *Translator, bin_op: parser.BinaryOperationNode) File {
        var res = File.init("_", self.allocator);

        var lhs_res = self.translateNode(bin_op.lhs.*);
        var lhs_node = self.allocator.create(Node) catch unreachable;
        lhs_node.* = lhs_res.source.pop();
        res.append(&lhs_res);

        var rhs_res = self.translateNode(bin_op.rhs.*);
        var rhs_node = self.allocator.create(Node) catch unreachable;
        rhs_node.* = rhs_res.source.pop();
        res.append(&rhs_res);

        var operator: Operator = undefined;
        switch (bin_op.operator) {
            .Add => operator = .Add,
            .Subtract => operator = .Subtract,
            .Multiply => operator = .Multiply,
            .Divide => operator = .Divide,
            .Assignment => operator = .Assignment,
        }

        res.source.append(Node {
            .BinaryOperation = BinaryOperationNode {
                .lhs = lhs_node,
                .operator = operator,
                .rhs = rhs_node,
            }
        }) catch unreachable;

        return res;
    }

    fn translateNode(self: *Translator, node: parser.Node) File {
        var res = File.init("_", self.allocator);
        switch (node) {
            .Value => |value| res.source.append(self.translateValueNode(value)) catch unreachable,
            .FunctionDefinition => |function_def| res.append(&self.translateFunctionDefinition(function_def)),
            .FunctionCall => |function_call| res.source.append(self.translateFunctionCall(function_call)) catch unreachable,
            .Use => |use| {
                if (self.translateUse(use)) |res_node| {
                    res.header.append(res_node) catch unreachable;
                } 
            },
            .Return => |ret| res.append(&self.translateReturn(ret)),
            .VariableDefinition => |var_def| res.append(&self.translateVariableDefinition(var_def)),
            .VariableCall => |var_call| res.append(&self.translateVariableCall(var_call)),
            .BinaryOperation => |bin_op| res.append(&self.translateBinaryOperation(bin_op)),
        }
        return res;
    }

    pub fn translate(self: *Translator) Project {
        var project = Project.init(self.allocator);

        while (self.getCurrent()) |current| {
            const res = self.translateNode(current);
            const file = if (std.mem.eql(u8, res.name, "_")) project.getFile("main")
            else project.getFile(res.name);
            file.append(&res);
            self.advance();
        }

        // Generate links between .h and .c
        for (project.files.items) |*file| {
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
        }

        return project;
    }

};