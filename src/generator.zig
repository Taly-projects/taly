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
                } else if (return_type != null) {
                    var return_value: ?*parser.Node = self.allocator.create(parser.Node) catch unreachable;
                    return_value.?.* = gen;
                    gen = . {
                        .Return = . {
                            .value = return_value
                        }
                    };
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
                .constructor = node.constructor,
                .body = body
            }
        };
    }

    fn generateClass(self: *Generator, class: parser.ClassNode) parser.Node {
        var body = parser.NodeList.init(self.allocator);

        for (class.body.items) |node| {
            if (node == parser.NodeTag.FunctionDefinition) {
                if (node.FunctionDefinition.constructor) {
                    var f_body = parser.NodeList.init(self.allocator);
                    f_body.append(parser.Node {
                        .VariableDefinition = parser.VariableDefinitionNode {
                            .constant = false,
                            .name = "self_data",
                            .data_type = class.name,
                            .value = null
                        }
                    }) catch unreachable;
                    f_body.append(parser.Node {
                        .CI_PureC = parser.CI_PureCNode {
                            .code = std.mem.concat(self.allocator, u8, &[_][]const u8 {class.name, "* self = &self_data;"}) catch unreachable
                        }
                    }) catch unreachable;
                    f_body.appendSlice(node.FunctionDefinition.body.items) catch unreachable;
                    var return_value = self.allocator.create(parser.Node) catch unreachable;
                    return_value.* = parser.Node {
                        .VariableCall = parser.VariableCallNode {
                            .name = "self_data"
                        }
                    };
                    f_body.append(parser.Node {
                        .Return = parser.ReturnNode {
                            .value = return_value
                        }
                    }) catch unreachable;

                    var node_cpy = node;
                    node_cpy.FunctionDefinition.return_type = class.name;
                    node_cpy.FunctionDefinition.body = f_body;
                    body.append(node_cpy) catch unreachable;
                } else {
                    var params = parser.FunctionDefinitionParameters.init(self.allocator);
                    params.append(parser.FunctionDefinitionParameter {
                        .name = "self",
                        .data_type = std.mem.concat(self.allocator, u8, &[_][]const u8{class.name, "*"}) catch unreachable
                    }) catch unreachable;
                    params.appendSlice(node.FunctionDefinition.parameters.items) catch unreachable;
                    var node_cpy = node;
                    node_cpy.FunctionDefinition.parameters = params;
                    body.append(node_cpy) catch unreachable;
                }
            } else {
                body.append(node) catch unreachable;
            }
        }

        return parser.Node {
            .Class = parser.ClassNode {
                .name = class.name,
                .body = body
            }
        };
    }

    fn generateNode(self: *Generator, node: parser.Node) parser.Node {
        switch (node) {
            .FunctionDefinition => |fun_def| return self.generateFunctionDefinition(fun_def),
            .Class => |class| return self.generateClass(class),
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