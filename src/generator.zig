const std = @import("std");
const parser = @import("parser.zig");

pub const Generator = struct {
    allocator: std.mem.Allocator,
    ast: parser.NodeList,
    index: usize = 0,

    pub fn init(ast: parser.NodeList, allocator: std.mem.Allocator) Generator {
        return Generator {
            .allocator = allocator,
            .ast = ast
        };
    }

    fn getCurrent(self: *const Generator) ?parser.Node {
        if (self.index >= self.ast.items.len) return null;
        return self.ast.items[self.index];
    }

    fn advance(self: *Generator) void {
        self.index += 1;
    }

    fn generateFunctionDefinition(self: *Generator, node: parser.FunctionDefinitionNode) parser.Node {
        var return_type = node.return_type;
        if (std.mem.eql(u8, node.name, "main")) {
            if (return_type == null) return_type = "c_int";
        }

        var body = parser.NodeList.init(self.allocator);
        var i: usize = 0;
        for (node.body.items) |child| {
            var gen = self.generateNode(child);
            if (i == node.body.items.len - 1) {
                if (std.mem.eql(u8, node.name, "main")) {
                    if (gen != parser.NodeTag.Return) {
                        var return_value: ?*parser.Node = self.allocator.create(parser.Node) catch unreachable;
                        body.append(gen) catch unreachable;
                        return_value.?.* = . { 
                            .Value = . { 
                                .Int = "0"
                            }
                        };
                        gen = . {
                            .Return = . {
                                .value = return_value
                            }
                        };
                    }
                } else {
                    var return_value: ?*parser.Node = self.allocator.create(parser.Node) catch unreachable;
                    return_value.?.* = gen;
                    gen = . {
                        .Return = . {
                            .value = return_value
                        }
                    };
                    // TODO: Automatic return
                }
            }
            body.append(gen) catch unreachable;
        }

        return parser.Node {
            .FunctionDefinition = . {
                .name = node.name,
                .parameters = node.parameters,
                .return_type = return_type,
                .external = node.external,
                .body = body
            }
        };
    }

    fn generateNode(self: *Generator, node: parser.Node) parser.Node {
        switch (node) {
            .FunctionDefinition => |fun_def| return self.generateFunctionDefinition(fun_def),
            else => return node
        }
    }

    pub fn generate(self: *Generator) parser.NodeList {
        var ast = parser.NodeList.init(self.allocator);

        while (self.getCurrent()) |current| {
            ast.append(self.generateNode(current)) catch unreachable;
            self.advance();
        } 

        return ast;
    }
};