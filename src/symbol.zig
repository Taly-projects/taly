const std = @import("std");
const parser = @import("parser.zig");

pub const VariableSymbol = struct {
    name: []const u8,
    data_type: []const u8,
    constant: bool,
    initialized: bool,

    pub fn writeXML(self: *const VariableSymbol, writer: anytype, tabs: usize, id: usize, node_id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<variable id=\"{d}\" node-id=\"{d}\">\n", .{id, node_id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<type>{s}</type>\n", .{self.data_type});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<constant>{}</constant>\n", .{self.constant});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<initialized>{}</initialized>\n", .{self.initialized});

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</variable>\n");
    }
    
};

pub const FunctionSymbol = struct {
    external: bool,
    constructor: bool,
    variadic: bool = false,
    name: []const u8,
    parameters: parser.FunctionDefinitionParameters,
    return_type: ?[]const u8,
    children: SymbolList,

    pub fn writeXML(self: *const FunctionSymbol, writer: anytype, tabs: usize, id: usize, node_id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<function id=\"{d}\" node-id=\"{d}\">\n", .{id, node_id});

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

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<return-type>{s}</return-type>\n", .{self.return_type orelse "void"});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<parameters>");

        for (self.parameters.items) |param| {
            try writer.writeAll("\n");
            try param.writeXML(writer, tabs + 2);
        }

        if (self.parameters.items.len != 0) {
            try writer.writeAll("\n");

            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</parameters>\n");

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<children>");
        if (self.children.items.len != 0) try writer.writeAll("\n");

        for (self.children.items) |child| {
            try child.writeXML(writer, tabs + 2);
        }

        if (self.children.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</children>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</function>\n");
    }

};

pub const ClassSymbol = struct {
    sealed: bool,
    name: []const u8,
    children: SymbolList,

    pub fn writeXML(self: *const ClassSymbol, writer: anytype, tabs: usize, id: usize, node_id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<class id=\"{d}\" node-id=\"{d}\">\n", .{id, node_id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<sealed>{}</sealed>\n", .{self.sealed});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<children>");
        if (self.children.items.len != 0) try writer.writeAll("\n");

        for (self.children.items) |child| {
            
            try child.writeXML(writer, tabs + 2);
        }

        if (self.children.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</children>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</class>\n");
    }
};

pub const BlockSymbol = struct {
    children: SymbolList,

    pub fn writeXML(self: *const BlockSymbol, writer: anytype, tabs: usize, id: usize, node_id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<block id=\"{d}\" node-id=\"{d}\">\n", .{id, node_id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("<children>");
        if (self.children.items.len != 0) try writer.writeAll("\n");

        for (self.children.items) |child| {
            
            try child.writeXML(writer, tabs + 2);
        }

        if (self.children.items.len != 0) {
            // Add tabs
            i = 0;
            while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");
        }
        try writer.writeAll("</children>\n");

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</block>\n");
    }
};

pub const TypeAliasSymbol = struct {
    name: []const u8,
    value: []const u8,

    pub fn writeXML(self: *const TypeAliasSymbol, writer: anytype, tabs: usize, id: usize, node_id: usize) anyerror!void {
        // Add tabs
        var i: usize = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<type-alias id=\"{d}\" node-id=\"{d}\">\n", .{id, node_id});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<name>{s}</name>\n", .{self.name});

        // Add tabs
        i = 0;
        while (i < tabs + 1) : (i += 1) try writer.writeAll("\t");

        try std.fmt.format(writer, "<value>{s}</value>\n", .{self.value});

        // Add tabs
        i = 0;
        while (i < tabs) : (i += 1) try writer.writeAll("\t");

        try writer.writeAll("</type-alias>\n");
    }
};

pub const SymbolTag = enum {
    Variable,
    Function,
    Class,
    Block,
    TypeAlias,
};

pub const SymbolData = union(SymbolTag) {
    Variable: VariableSymbol,
    Function: FunctionSymbol,
    Class: ClassSymbol,
    Block: BlockSymbol,
    TypeAlias: TypeAliasSymbol,
};

pub const Symbol = struct {
    pub const NO_ID: usize = 0;

    var ID: usize = 1;

    data: SymbolData,
    id: usize,
    node_id: usize,

    pub fn gen(data: SymbolData, node_id: usize) Symbol {
        const self = Symbol {
            .data = data,
            .id = ID,
            .node_id = node_id
        };
        ID += 1;
        return self;
    }

    pub fn getSymbol(self: *Symbol, id: usize) ?*Symbol {
        if (self.id == id) return self;

        switch (self.data) {
            .Function => |*function| {
                for (function.children.items) |*child| {
                    if (child.getSymbol(id)) |sym| return sym;
                } 
            },
            .Class => |*class| {
                for (class.children.items) |*child| {
                    if (child.getSymbol(id)) |sym| return sym;
                } 
            },
            .Block => |*block| {
                for (block.children.items) |*child| {
                    if (child.getSymbol(id)) |sym| return sym;
                } 
            },
            else => {}
        }

        return null;
    }

    pub fn getClass(self: *Symbol, name: []const u8) ?*Symbol {
        if (self.data == SymbolTag.Class) {
            if (std.mem.eql(u8, self.data.Class.name, name)) return self;
        }

        return null;
    }

    pub fn getAlias(self: *Symbol, name: []const u8) ?*Symbol {
        if (self.data == SymbolTag.TypeAlias) {
            if (std.mem.eql(u8, self.data.TypeAlias.name, name)) return self;
        }

        return null;
    }

    pub fn writeXML(self: *const Symbol, writer: anytype, tabs: usize) !void {
        switch (self.data) {
            .Variable => |node| return node.writeXML(writer, tabs, self.id, self.node_id),
            .Function => |node| return node.writeXML(writer, tabs, self.id, self.node_id),
            .Class => |node| return node.writeXML(writer, tabs, self.id, self.node_id),
            .Block => |node| return node.writeXML(writer, tabs, self.id, self.node_id),
            .TypeAlias => |node| return node.writeXML(writer, tabs, self.id, self.node_id),
        }
    }
};

pub const SymbolList = std.ArrayList(Symbol);