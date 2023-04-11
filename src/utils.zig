const std = @import("std");
const parser = @import("parser.zig");

pub fn process_node_name(allocator: std.mem.Allocator, node: parser.Node) []const u8 {
    switch (node.data) {
        .VariableCall => |var_call| return var_call.name,
        .GenericCall => |gen_call| {
            var buf = std.ArrayList(u8).init(allocator);
            buf.writer().writeAll(gen_call.name) catch unreachable;
            for (gen_call.parameters.items) |param| {
                buf.append('_') catch unreachable;
                buf.writer().writeAll(process_node_name(allocator, param)) catch unreachable;
            }
            return buf.items;
        },
        .PointerCall => @panic("todo"),
        else => unreachable
    }
}

pub fn translateType(data_type: []const u8) []const u8 {
    if (std.mem.eql(u8, data_type, "c_int")) return "int"
    else if (std.mem.eql(u8, data_type, "c_float")) return "float"
    else if (std.mem.eql(u8, data_type, "c_string")) return "const char*";

    return data_type;
}