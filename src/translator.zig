const std = @import("std");
const parser = @import("parser.zig");

pub const ValueNodeTag = enum {
    String
};

pub const ValueNode = union(ValueNodeTag) {
    String: []const u8,

    pub fn writeC(self: *const ValueNode, writer: anytype, tabs: usize) anyerror!bool {
        switch (self.*) {
            .String => |str| {
                // Add tabs
                var i: usize = 0;
                while (i < tabs) : (i += 1) try writer.writeAll("\t");

                try std.fmt.format(writer, "\"{s}\"", .{str});
                return true;
            }
        }
    }

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

    pub fn writeC(self: *const FunctionDefinitionParameter, writer: anytype) anyerror!void {
        try std.fmt.format(writer, "{s} {s}", .{ self.data_type, self.name });
    }

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

    pub fn writeXML(self: *const FunctionHeader, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<function-header>\n");

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
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</function-header>\n");
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
            if (i == 0) try writer.writeAll("\n");
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
            try writer.writeAll("}");
        }
        return false;
    }

    pub fn writeXML(self: *const FunctionSource, writer: anytype, tabs: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<function-source>\n");

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

        try writer.writeAll("</function-source>\n");
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

pub const NodeTag = enum {
    Value,
    FunctionHeader,
    FunctionSource,
    FunctionCall
};

pub const Node = union(NodeTag) {
    Value: ValueNode,
    FunctionHeader: FunctionHeader,
    FunctionSource: FunctionSource,
    FunctionCall: FunctionCallNode,

    pub fn writeC(self: *const Node, writer: anytype, tabs: usize) anyerror!bool {
        switch (self.*) {
            .Value => |node| return node.writeC(writer, tabs),
            .FunctionHeader => |node| return node.writeC(writer, tabs),
            .FunctionSource => |node| return node.writeC(writer, tabs),
            .FunctionCall => |node| return node.writeC(writer, tabs),
        }
    }

    pub fn writeXML(self: *const Node, writer: anytype, tabs: usize) anyerror!void {
        switch (self.*) {
            .Value => |node| return node.writeXML(writer, tabs),
            .FunctionHeader => |node| return node.writeXML(writer, tabs),
            .FunctionSource => |node| return node.writeXML(writer, tabs),
            .FunctionCall => |node| return node.writeXML(writer, tabs),
        }
    }

    pub fn format(self: *const Node, comptime fmt: []const u8, options: anytype, writer: anytype) !void {
        _ = options;
        _ = fmt;

        switch (self.*) {
            .Value => |node| node.writeXML(writer, 0) catch unreachable,
            .FunctionHeader => |node| node.writeXML(writer, 0) catch unreachable,
            .FunctionSource => |node| node.writeXML(writer, 0) catch unreachable,
            .FunctionCall => |node| node.writeXML(writer, 0) catch unreachable,
        }
    }
};

pub const NodeList = std.ArrayList(Node);

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

    fn translateValueNode(self: *Translator, value: parser.ValueNode) Node {
        _ = self;
        switch (value) {
            .String => |str| return Node { .Value = . { .String = str } }
        }
    }

    fn translateFunctionDefinition(self: *Translator, function_def: parser.FunctionDefinitionNode) NodeList {
        var res = NodeList.init(self.allocator);

        var parameters = FunctionDefinitionParameters.init(self.allocator);
        for (function_def.parameters.items) |param| {
            parameters.append(FunctionDefinitionParameter {
                .name = param.name,
                .data_type = param.data_type
            }) catch unreachable;
        }

        if (!std.mem.eql(u8, function_def.name, "main")) {
            res.append(Node {
                .FunctionHeader = .{
                    .name = function_def.name,
                    .parameters = parameters,
                    .return_type = function_def.return_type orelse "void"
                }
            }) catch unreachable; 
        }

        var body = NodeList.init(self.allocator);
        for (function_def.body.items) |node| {
            body.appendSlice(self.translateNode(node).items) catch unreachable;
        }

        res.append(Node {
            .FunctionSource = .{
                .name = function_def.name,
                .parameters = parameters,
                .return_type = function_def.return_type orelse "void",
                .body = body
            }
        }) catch unreachable; 

        return res;
    }

    fn translateFunctionCall(self: *Translator, function_call: parser.FunctionCallNode) Node {
        var parameters = NodeList.init(self.allocator);
        for (function_call.parameters.items) |param| {
            parameters.appendSlice(self.translateNode(param).items) catch unreachable;
        }

        return Node {
            .FunctionCall = . {
                .name = function_call.name,
                .parameters = parameters
            }
        };
    }

    fn translateNode(self: *Translator, node: parser.Node) NodeList {
        var res = NodeList.init(self.allocator);
        switch (node) {
            .Value => |value| res.append(self.translateValueNode(value)) catch unreachable,
            .FunctionDefinition => |function_def| res.appendSlice(self.translateFunctionDefinition(function_def).items) catch unreachable,
            .FunctionCall => |function_call| res.append(self.translateFunctionCall(function_call)) catch unreachable,
        }
        return res;
    }

    pub fn translate(self: *Translator) NodeList {
        var ast = NodeList.init(self.allocator);

        while (self.getCurrent()) |current| {
            ast.appendSlice(self.translateNode(current).items) catch unreachable;
            self.advance();
        }

        return ast;
    }

};