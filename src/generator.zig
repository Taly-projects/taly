const std = @import("std");
const position = @import("position.zig");
const parser = @import("parser.zig");
const taly = @import("taly.zig");
const utils = @import("utils.zig");

pub const Scope = struct {
    parent: ?*Scope = null,
    scope: ?*parser.Symbol = null,
    entered: ?*parser.Symbol = null,

    pub fn acceptsStatement(self: *const Scope) bool {
        if (self.scope) |scope| {
            switch (scope.data) {
                .Function, .Block => return true,
                else => {},
            }
        }

        if (self.parent) |parent| {
            return parent.acceptsStatement();
        } 
        
        return false;
    }

    pub fn acceptsVariableDefinition(self: *const Scope) bool {
        if (self.entered != null) unreachable;

        if (self.scope) |scope| {
            switch (scope.data) {
                .Function, .Block, .Class, .Prototype => return true,
                else => {},
            }
        }

        if (self.parent) |parent| {
            return parent.acceptsVariableDefinition();
        } 
        
        return false;
    }
    pub fn acceptsFunctionDefinition(self: *const Scope) bool {
        if (self.entered != null) unreachable;

        if (self.scope) |scope| {
            switch (scope.data) {
                .Class, .Prototype, .Interface => return true,
                else => {},
            }
        } else {
            return true;
        }

        if (self.parent) |parent| {
            return parent.acceptsFunctionDefinition();
        } 
        
        return false;
    }

    pub fn acceptsClassDefinition(self: *const Scope) bool {
        if (self.entered != null) unreachable;

        if (self.scope) |scope| {
            switch (scope.data) {
                else => {},
            }
        } else {
            return true;
        }

        return false;
    }

    pub fn getFunction(self: *const Scope, root: *const parser.SymbolList, name: []const u8) ?*parser.Symbol {
        if (self.entered) |entered| {
            switch (entered.data) {
                .Class => |class| {
                    for (class.children.items) |*sym| {
                        switch (sym.data) {
                            .Function => |function| {
                                if (std.mem.eql(u8, function.name, name)) {
                                    return sym;
                                }
                            },
                            else => {}
                        }
                    }
                },
                else => {}
            } 

            return null; 
        }

        if (self.scope) |scope| {
            switch (scope.data) {
                .Class => |class| {
                    for (class.children.items) |*sym| {
                        switch (sym.data) {
                            .Function => |function| {
                                if (std.mem.eql(u8, function.name, name)) {
                                    return sym;
                                } 
                            },
                            else => {}
                        }
                    }
                },
                else => {}
            }
        } else {
            // Root
            for (root.items) |*sym| {
                switch (sym.data) {
                    .Function => |function| {
                        if (std.mem.eql(u8, function.name, name)) {
                            return sym;
                        } 
                    },
                    else => {}
                }
            }
        }

        if (self.parent) |parent| {
            return parent.getFunction(root, name);
        }
   
        return null;
    }

    pub fn getVariable(self: *const Scope, root: *const parser.SymbolList, name: []const u8) ?*parser.Symbol {
        if (self.entered) |entered| {
            switch (entered.data) {
                .Function => |function| {
                    for (function.children.items) |*sym| {
                        switch (sym.data) {
                            .Variable => |variable| {
                                if (std.mem.eql(u8, variable.name, name)) {
                                    return sym;
                                }
                            },
                            else => {}
                        }
                    }
                },
                .Class => |class| {
                    for (class.children.items) |*sym| {
                        switch (sym.data) {
                            .Variable => |variable| {
                                if (std.mem.eql(u8, variable.name, name)) {
                                    return sym;
                                }
                            },
                            else => {}
                        }
                    }
                },
                else => {}
            } 

            return null; 
        }

        if (self.scope) |scope| {
            switch (scope.data) {
                .Class => |class| {
                    for (class.children.items) |*sym| {
                        switch (sym.data) {
                            .Variable => |variable| {
                                if (std.mem.eql(u8, variable.name, name)) {
                                    return sym;
                                } 
                            },
                            else => {}
                        }
                    }
                },
                .Function => |function| {
                    for (function.children.items) |*sym| {
                        switch (sym.data) {
                            .Variable => |variable| {
                                if (std.mem.eql(u8, variable.name, name)) {
                                    return sym;
                                } 
                            },
                            else => {}
                        }
                    }
                },
                else => {}
            }
        } else {
            // Root
            for (root.items) |*sym| {
                switch (sym.data) {
                    .Variable => |variable| {
                        if (std.mem.eql(u8, variable.name, name)) {
                            return sym;
                        } 
                    },
                    else => {}
                }
            }
        }

        if (self.parent) |parent| {
            return parent.getVariable(root, name);
        }
   
        return null;
    }

    pub fn getClass(self: *const Scope, root: *const parser.SymbolList, name: []const u8) ?*parser.Symbol {
        if (self.entered) |entered| {
            _ = entered;
            return null; 
        }

        if (self.scope) |scope| {
            _ = scope;
        } else {
            // Root
            for (root.items) |*sym| {
                switch (sym.data) {
                    .Class => |class| {
                        if (std.mem.eql(u8, class.name, name)) {
                            return sym;
                        } 
                    },
                    else => {}
                }
            }
        }

        if (self.parent) |parent| {
            return parent.getClass(root, name);
        }
   
        return null;
    }
    
    pub fn getAlias(self: *const Scope, root: *const parser.SymbolList, name: []const u8) ?*parser.Symbol {
        if (self.entered) |entered| {
            _ = entered;
            return null; 
        }

        if (self.scope) |scope| {
            _ = scope;
        } else {
            // Root
            for (root.items) |*sym| {
                switch (sym.data) {
                    .TypeAlias => |alias| {
                        if (std.mem.eql(u8, alias.name, name)) {
                            return sym;
                        } 
                    },
                    else => {}
                }
            }
        }

        if (self.parent) |parent| {
            return parent.getAlias(root, name);
        }
   
        return null;
    }

    pub fn getParentClass(self: *const Scope) ?*parser.Symbol {
        if (self.parent) |parent| {
            if (parent.scope) |scope| {
                switch (scope.data) {
                    .Class => return scope,
                    else => {}
                }
            }

            return parent.getParentClass();
        }
        return null;
    }

    pub fn getParentInterface(self: *const Scope) ?*parser.Symbol {
        if (self.parent) |parent| {
            if (parent.scope) |scope| {
                switch (scope.data) {
                    .Interface => return scope,
                    else => {}
                }
            }

            return parent.getParentInterface();
        }
        return null;
    }

    pub fn getParentPrototype(self: *const Scope) ?*parser.Symbol {
        if (self.parent) |parent| {
            if (parent.scope) |scope| {
                switch (scope.data) {
                    .Prototype => return scope,
                    else => {}
                }
            }

            return parent.getParentPrototype();
        }
        return null;
    }

    pub fn isGeneric(self: *const Scope, name: []const u8) bool {
        if (self.parent) |parent| {
            if (parent.scope) |scope| {
                switch (scope.data) {
                    .Interface => |intf| {
                        for (intf.generics.items) |extension| {
                            if (std.mem.eql(u8, extension, name)) return true;
                        }
                    },
                    else => {}
                }
            }

            return parent.isGeneric(name);
        }
        return false;
    }
};


pub const Generator = struct {
    file_name: []const u8,
    src: []const u8,
    allocator: std.mem.Allocator,
    ast: parser.NodeList,
    infos: parser.NodeInfos,
    symbols: parser.SymbolList,
    scope: Scope = Scope{},
    index: usize = 0,

    pub fn init(file_name: []const u8, src: []const u8, ast: parser.NodeList, infos: parser.NodeInfos, symbols: parser.SymbolList, allocator: std.mem.Allocator) Generator {
        return Generator {
            .file_name = file_name,
            .src = src,
            .allocator = allocator,
            .ast = ast,
            .infos = infos,
            .symbols = symbols,
        };
    }

    fn getCurrent(self: *const Generator) ?parser.Node {
        if (self.index >= self.ast.items.len) return null;
        return self.ast.items[self.index];
    }

    fn advance(self: *Generator) void {
        self.index += 1;
    }

    fn getInfo(self: *const Generator, id: usize) ?*parser.NodeInfo {
        for (self.infos.items) |*info| {
            if (info.node_id == id) return info;
        }
        return null;
    }

    fn getSymbol(self: *const Generator, id: usize) ?*parser.Symbol {
        for (self.symbols.items) |*sym| {
            if (sym.getSymbol(id)) |sym2| return sym2;
        }

        return null;
    }

    fn getClass(self: *const Generator, name: []const u8) ?*parser.Symbol {
        for (self.symbols.items) |*sym| {
            if (sym.getClass(name)) |sym2| return sym2;
        }

        return null;
    }

    fn getAlias(self: *const Generator, name: []const u8) ?*parser.Symbol {
        for (self.symbols.items) |*sym| {
            if (sym.getAlias(name)) |sym2| return sym2;
        }

        return null;
    }

    fn getInterface(self: *const Generator, name: []const u8) ?*parser.Symbol {
        for (self.symbols.items) |*sym| {
            if (sym.getInterface(name)) |sym2| return sym2;
        }

        return null;
    }

    fn addSymbol(self: *Generator, symbol: parser.Symbol) void {
        if (self.scope.scope) |scope| {
            switch (scope.data) {
                .Function => |*function| function.children.append(symbol) catch unreachable,
                .Class => |*class| class.children.append(symbol) catch unreachable,
                .Block => |*block| block.children.append(symbol) catch unreachable,
                else => unreachable
            }
        } else {
            self.symbols.append(symbol) catch unreachable;
        }
    }

    fn generateValue(self: *Generator, node: parser.Node) parser.Node {
        const info = self.getInfo(node.id).?;
        
        // Check if possible
        if (!self.scope.acceptsStatement()) {
            info.position.errorMessage("Unexpected Value Node!", .{});
        }

        
        // Genreate type info
        info.data_type = self.allocator.create(parser.Node) catch unreachable;
        switch (node.data.Value) {
            .String => info.data_type.?.* = parser.Node {
                .id = parser.Node.NO_ID,
                .data = parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                    .name = "c_string" 
                    }
                }
            },
            .Int => info.data_type.?.* = parser.Node {
                .id = parser.Node.NO_ID,
                .data = parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                    .name = "c_int" 
                    }
                }
            },
            .Float => info.data_type.?.* = parser.Node {
                .id = parser.Node.NO_ID,
                .data = parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                    .name = "c_float" 
                    }
                }
            },
            .Bool => info.data_type.?.* = parser.Node {
                .id = parser.Node.NO_ID,
                .data = parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                    .name = "c_bool" 
                    }
                }
            },
        }

        return node;
    }

    fn generateFunctionDefinition(self: *Generator, node: parser.Node) parser.Node {
        const info = self.getInfo(node.id).?;

        // Check if possible
        if (!self.scope.acceptsFunctionDefinition()) {
            info.position.errorMessage("Unexpected Function Definition!", .{});
        }

        // Clone node to be able to modify it while keeping the previous values
        var new_node = node;

        // Enter scope
        const sym = self.getSymbol(info.symbol_def.?).?;
        const scope = Scope {
            .parent = self.allocator.create(Scope) catch unreachable,
            .scope = sym
        };
        scope.parent.?.* = self.scope;
        self.scope = scope;

        // Contains the new node
        var body = parser.NodeList.init(self.allocator);

        // Check if method
        var is_constructor = false;
        var is_class = false;
        var parameters = parser.FunctionDefinitionParameters.init(self.allocator);
        if (self.scope.getParentClass()) |class| {
            is_class = true;
            info.renamed = std.mem.concat(self.allocator, u8, &[_][]const u8 {class.data.Class.name, "_", node.data.FunctionDefinition.name}) catch unreachable;

            if (node.data.FunctionDefinition.constructor) {
                // Generate _self_data
                const self_data_node = parser.Node.gen(parser.NodeData {
                    .CI_PureC = parser.CI_PureCNode {
                        .code = std.mem.concat(self.allocator, u8, &[_][]const u8{ class.data.Class.name, " _self_data;" }) catch unreachable
                    }
                });
                body.append(self_data_node) catch unreachable;

                // Generate self
                const self_node = parser.Node.gen(parser.NodeData {
                    .CI_PureC = parser.CI_PureCNode {
                        .code = std.mem.concat(self.allocator, u8, &[_][]const u8{ class.data.Class.name, " *self = &_self_data;" }) catch unreachable
                    }
                });
                body.append(self_node) catch unreachable;

                var self_type = self.allocator.create(parser.Node) catch unreachable;
                self_type.* = parser.Node.gen(parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                        .name = class.data.Class.name
                    }
                });
                self.addSymbol(parser.Symbol.gen(parser.SymbolData {
                    .Variable = parser.VariableSymbol {
                        .name = "self",
                        .data_type = parser.Node.gen(parser.NodeData {
                            .PointerCall = parser.PointerCallNode {
                                .node = self_type
                            }
                        }),
                        .initialized = true,
                        .constant = true,
                    }
                }, parser.Node.NO_ID));

                // Update return type
                new_node.data.FunctionDefinition.return_type = self.allocator.create(parser.Node) catch unreachable;
                new_node.data.FunctionDefinition.return_type.?.* = parser.Node.gen(parser.NodeData {
                    .VariableCall = parser.VariableCallNode {
                        .name = class.data.Class.name
                    }
                });
                sym.data.Function.return_type = new_node.data.FunctionDefinition.return_type;
                self.infos.append(parser.NodeInfo {
                    .node_id = new_node.id,
                    .position = info.position,
                    .symbol_call = class.id
                }) catch unreachable;

                is_constructor = true;
            } else {
                // Check if it's part of the extensions
                var extension_sym: ?*parser.Symbol = null;
                var extension_fun: ?*parser.Symbol = null;
                var extension_node: ?*parser.Node = null;
                A: for (class.data.Class.extensions.items) |*extension_node_temp| {
                    // Get name from extension
                    var extension_name: []const u8 = undefined;
                    switch (extension_node_temp.data) {
                        .VariableCall => |var_call| extension_name = var_call.name,
                        .GenericCall => |gen_call| extension_name = gen_call.name, 
                        .PointerCall => @panic("todo"),
                        else => unreachable
                    }

                    const extension = self.getInterface(extension_name).?;
                    for (extension.data.Interface.children.items) |*child| {
                        if (std.mem.eql(u8, child.data.Function.name, sym.data.Function.name)) {
                            extension_sym = extension;
                            extension_fun = child;
                            extension_node = extension_node_temp;
                            break :A;
                        }
                    }
                }

                if (extension_sym != null) {
                    // Get class extension (extension node in the class)
                    info.renamed = std.mem.concat(self.allocator, u8, &[_][]const u8 {info.renamed.?, "_", utils.process_node_name(self.allocator, extension_node.?.*)}) catch unreachable;


                    // TODO: Check if parameters match
                    // TODO: Check if return type match

                    // Add self
                    var void_type = self.allocator.create(parser.Node) catch unreachable;
                    void_type.* = parser.Node.gen(parser.NodeData {
                        .VariableCall = parser.VariableCallNode {
                            .name = "void"
                        }
                    });
                    var void_ptr_type = self.allocator.create(parser.Node) catch unreachable;
                    void_ptr_type.* = parser.Node.gen(parser.NodeData {
                        .PointerCall = parser.PointerCallNode {
                            .node = void_type
                        }
                    });
                    parameters.append(parser.FunctionDefinitionParameter {
                        .name = "self_void",
                        .data_type = void_ptr_type,
                    }) catch unreachable;
                    
                    // Convert self
                    var value = self.allocator.create(parser.Node) catch unreachable;
                    value.* = parser.Node.gen(parser.NodeData {
                        .CI_PureC = parser.CI_PureCNode {
                            .code = std.mem.concat(self.allocator, u8, &[_][]const u8 { "(", utils.translateType(class.data.Class.name), "*) self_void"}) catch unreachable,
                        }
                    });
                    var self_type = self.allocator.create(parser.Node) catch unreachable;
                    self_type.* = parser.Node.gen(parser.NodeData {
                        .VariableCall = parser.VariableCallNode {
                            .name = class.data.Class.name
                        }
                    });
                    var self_ptr_type = self.allocator.create(parser.Node) catch unreachable;
                    self_ptr_type.* = parser.Node.gen(parser.NodeData {
                        .PointerCall = parser.PointerCallNode {
                            .node = self_type
                        }
                    });
                    // Generate node
                    const self_var = parser.Node.gen(parser.NodeData {
                        .VariableDefinition = parser.VariableDefinitionNode {
                            .constant = false,
                            .name = "self",
                            .data_type = self_ptr_type,
                            .value = value,
                        }
                    });
                    body.append(self_var) catch unreachable;

                    // Generate symbol
                    const self_sym = parser.Symbol.gen(parser.SymbolData {
                        .Variable = parser.VariableSymbol {
                            .name = "self",
                            .data_type = self_ptr_type.*,
                            .initialized = true,
                            .constant = true,
                        }
                    }, self_var.id);
                    self.addSymbol(self_sym);

                    // Generate info
                    self.infos.append(parser.NodeInfo {
                        .node_id = self_var.id,
                        .position = info.position,
                        .data_type = self_ptr_type,
                        .symbol_def = self_sym.id
                    }) catch unreachable;
                } else {
                    // Add self parameter
                    var self_type = self.allocator.create(parser.Node) catch unreachable;
                    self_type.* = parser.Node.gen(parser.NodeData {
                        .VariableCall = parser.VariableCallNode {
                            .name = class.data.Class.name
                        }
                    });
                    var self_ptr_type = self.allocator.create(parser.Node) catch unreachable;
                    self_ptr_type.* = parser.Node.gen(parser.NodeData {
                        .PointerCall = parser.PointerCallNode {
                            .node = self_type
                        }
                    });
                    parameters.append(parser.FunctionDefinitionParameter {
                        .name = "self",
                        .data_type = self_ptr_type
                    }) catch unreachable;
                }             

            }
        } else if (self.scope.getParentInterface()) |intf| {
            info.renamed = std.mem.concat(self.allocator, u8, &[_][]const u8 {intf.data.Interface.name, "_", node.data.FunctionDefinition.name}) catch unreachable;

            if (node.data.FunctionDefinition.constructor) {
                @panic("todo (no constructor in interfaces)");
            } else {
                // Add self parameter
                    var void_type = self.allocator.create(parser.Node) catch unreachable;
                    void_type.* = parser.Node.gen(parser.NodeData {
                        .VariableCall = parser.VariableCallNode {
                            .name = "void"
                        }
                    });
                    var void_ptr_type = self.allocator.create(parser.Node) catch unreachable;
                    void_ptr_type.* = parser.Node.gen(parser.NodeData {
                        .PointerCall = parser.PointerCallNode {
                            .node = void_type
                        }
                    });
                parameters.append(parser.FunctionDefinitionParameter {
                    .name = "super",
                    .data_type = void_ptr_type
                }) catch unreachable;
            }
        } else if (self.scope.getParentPrototype()) |proto| {
            info.renamed = std.mem.concat(self.allocator, u8, &[_][]const u8 {proto.data.Prototype.name, "_", node.data.FunctionDefinition.name}) catch unreachable;

            if (node.data.FunctionDefinition.constructor) {
                @panic("todo (no constructor in interfaces)");
            } else {
                // Add self parameter
                    var void_type = self.allocator.create(parser.Node) catch unreachable;
                    void_type.* = parser.Node.gen(parser.NodeData {
                        .VariableCall = parser.VariableCallNode {
                            .name = "void"
                        }
                    });
                    var void_ptr_type = self.allocator.create(parser.Node) catch unreachable;
                    void_ptr_type.* = parser.Node.gen(parser.NodeData {
                        .PointerCall = parser.PointerCallNode {
                            .node = void_type
                        }
                    });
                parameters.append(parser.FunctionDefinitionParameter {
                    .name = "super",
                    .data_type = void_ptr_type
                }) catch unreachable;
            }
        }
        parameters.appendSlice(node.data.FunctionDefinition.parameters.items) catch unreachable;

        // Create symbols for parameters
        for (parameters.items) |param| {
            self.addSymbol(parser.Symbol.gen(parser.SymbolData {
                .Variable = parser.VariableSymbol {
                    .name = param.name,
                    .data_type = param.data_type.*,
                    .constant = true,
                    .initialized = true
                }
            }, parser.Node.NO_ID));
        }
        new_node.data.FunctionDefinition.parameters = parameters;

        // Check body
        for (node.data.FunctionDefinition.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
        }

        // Check if return type is generic
        if (node.data.FunctionDefinition.return_type) |return_node| {
            if (return_node.data == parser.NodeTag.VariableCall) {
                if (self.scope.isGeneric(return_node.data.VariableCall.name)) {
                    const return_node_info = self.getInfo(return_node.id).?;
                    return_node_info.is_generic = true;
                }
            }
        }

        // Generate return
        if (is_constructor) {
            var returned_value = self.allocator.create(parser.Node) catch unreachable;
            returned_value.* = parser.Node.gen(parser.NodeData {
                .VariableCall = parser.VariableCallNode {
                    .name = "_self_data"
                }
            });
            body.append(parser.Node.gen(parser.NodeData {
                .Return = parser.ReturnNode {
                    .value = returned_value
                }
            })) catch unreachable;
        }

        if (node.data.FunctionDefinition.return_type != null) {
            if (body.popOrNull()) |last| {
                // TODO: Check type

                // Check if return
                var new_last = last;
                if (last.data != parser.NodeTag.Return) {
                    var value = self.allocator.create(parser.Node) catch unreachable;
                    value.* = last;
                    new_last = parser.Node.gen(parser.NodeData {
                        .Return = parser.ReturnNode {
                            .value = value 
                        }
                    });
                }

                body.append(new_last) catch unreachable;
            } else if(is_class) {
                @panic("todo (should return something)");
            }
        }

        new_node.data.FunctionDefinition.body = body;

        // TODO: If main => set return type and add return statement (if not present)
        // TODO: Check if return statments are present and match the return type
        // TODO: Check if doesn't already exists
        // TODO: Check if no duplicate paramter
        // TODO: If not main => Generate return if not present for the last node

        // Exit scope
        self.scope = self.scope.parent.?.*;
        
        return new_node;
    }

    fn generateFunctionCall(self: *Generator, node: parser.Node) parser.Node {
        // Check if possible
        if (!self.scope.acceptsStatement()) {
            @panic("todo");
        }

        // Find function symbol
        const function_symbol = self.scope.getFunction(&self.symbols, node.data.FunctionCall.name) orelse {
            const info = self.getInfo(node.id).?;
            info.position.errorMessage("Function `{s}` not declared!", .{node.data.FunctionCall.name});
        };

        // Check if parameters match (type + number)
        const specified_param_count = node.data.FunctionCall.parameters.items.len;
        const defined_param_count = function_symbol.data.Function.parameters.items.len;
        
        if (!function_symbol.data.Function.variadic and specified_param_count > defined_param_count) {
            const info = self.getInfo(node.id).?;
            info.position.errorMessageReturn("Not many parameters specified for function `{s}` !", .{node.data.FunctionCall.name});
            const symbol_info = self.getInfo(function_symbol.node_id).?;
            symbol_info.position.errorMessage("Defined here:", .{});
        } else if (specified_param_count < defined_param_count) {
            const info = self.getInfo(node.id).?;
            info.position.errorMessageReturn("Not enough parameters specified for function `{s}` !", .{node.data.FunctionCall.name});
            const symbol_info = self.getInfo(function_symbol.node_id).?;
            symbol_info.position.errorMessage("Defined here:", .{});
        }

        // Remove entered
        const entered = self.scope.entered;
        self.scope.entered = null;

        var parameters = parser.NodeList.init(self.allocator);
        var i: usize = 0;
        for (node.data.FunctionCall.parameters.items) |param| {
            const generated_param = self.generateNode(param);
            parameters.append(generated_param) catch unreachable;

            // Only check type if not part of variadic
            if (i < defined_param_count) {
                const defined_param = function_symbol.data.Function.parameters.items[i];
                _ = defined_param;
                
                const param_info = self.getInfo(generated_param.id).?;
                if (param_info.data_type) |data_type| {
                    _ = data_type;
                    // TODO: Check data type
                    // if (!std.mem.eql(u8, defined_param.data_type, data_type)) {
                    //     @panic("todo");
                    // }
                } else {
                    param.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                    @panic("todo (no info type)");
                }
            }

            i += 1;
        }
        self.scope.entered = entered;

        // Generate type info for node (based on return type of the function)
        const info = self.getInfo(node.id).?;
        info.data_type = function_symbol.data.Function.return_type;

        // Generate symbol link
        info.symbol_call = function_symbol.id;
        
        return node;
    }

    fn generateUse(self: *Generator, node: parser.Node) parser.Node {
        if (!std.mem.startsWith(u8, node.data.Use.path, "std-") and !std.mem.startsWith(u8, node.data.Use.path, "c-")) {
            const data = taly.CompilerData.compile(self.allocator, std.mem.concat(self.allocator, u8, &[_][]const u8 {node.data.Use.path, ".taly"}) catch unreachable) catch unreachable;
            self.infos.appendSlice(data.node_infos.?.items) catch unreachable;
            self.symbols.appendSlice(data.symbols.?.items) catch unreachable;
        }

        return node;
    }

    fn generateReturn(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Generate type info for node (based on type of value node)
        // TODO: Check scope (possible here)

        var new_node = node;

        // Check value node
        if (node.data.Return.value) |value| {
            new_node.data.Return.value.?.* = self.generateNode(value.*);
        }
        
        return new_node;
    }

    fn generateVariableDefinition(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsVariableDefinition()) {
            @panic("todo");
        }

        // Clone node to be able to modify it while keeping the previous values
        var new_node = node;

        // Check value
        if (node.data.VariableDefinition.value) |value| {
            const gen_value = self.generateNode(value.*);

            const value_info = self.getInfo(gen_value.id).?;
            if (value_info.data_type) |data_type| {
                _ = data_type;
                // TODO: Check type
                // if (!std.mem.eql(u8, data_type, node.data.VariableDefinition.data_type)) {
                //     var found = false;
                //     if (self.getAlias(data_type)) |alias| {
                //         if (std.mem.eql(u8, alias.data.TypeAlias.value, node.data.VariableDefinition.data_type)) {
                //             found = true;
                //         }
                //     }

                //     if (!found) {
                //         if (self.getAlias(node.data.VariableDefinition.data_type)) |alias| {
                //             if (std.mem.eql(u8, alias.data.TypeAlias.value, data_type)) {
                //                 found = true;
                //             }
                //         }
                //     }

                //     if (!found) {
                //         @panic("todo");
                //     }
                // }
            } else {
                @panic("todo");
            }
        
            new_node.data.VariableDefinition.value.?.* = gen_value;
        }
        

        // TODO: Check if doesn't already exists
        
        return new_node;
    }

    fn generateVariableCall(self: *Generator, node: parser.Node) parser.Node {
        const info = self.getInfo(node.id).?;
        
        // Check scope (possible here)
        if (!self.scope.acceptsStatement()) {
            info.position.errorMessage("Variable call is not possible here!", .{});    
        }

        // Check if exists
        var sym: *parser.Symbol = undefined;

        const var_name = if (self.scope.getAlias(&self.symbols, node.data.VariableCall.name)) |variable| blk: {
            break :blk variable.data.TypeAlias.value;
        } else node.data.VariableCall.name;

        if (self.scope.getVariable(&self.symbols, var_name)) |variable| {
            sym = variable;
            info.data_type = self.allocator.create(parser.Node) catch unreachable;
            info.data_type.?.* = sym.data.Variable.data_type;
        } else if (self.scope.getClass(&self.symbols, var_name)) |class| {
            sym = class;
        } else {
            // self.scope.scope.?.writeXML(std.io.getStdOut().writer(), 1) catch unreachable;
            // self.scope.entered.?.writeXML(std.io.getStdOut().writer(), 1) catch unreachable;
            info.position.errorMessageReturn("", .{});
            std.log.info("{s} {}", .{var_name, self.scope.entered == null});
            @panic("todo");
        }

        // TODO: Check if exists

        // Generate symbol link
        info.symbol_call = sym.id;

        return node;
    }

    fn generateBinaryOperation(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsStatement()) {
            @panic("todo");
        }
        
        // TODO: If Assignment check if lhs is assignable
        // TODO: else check if types match (later change to implementation)
        // TODO: Generate type info

        var new_node = node;

        if (node.data.BinaryOperation.operator == parser.Operator.Access) {
            // Generate LHS
            const gen_lhs = self.generateNode(node.data.BinaryOperation.lhs.*);
            const lhs_info = self.getInfo(gen_lhs.id).?;

            if (lhs_info.symbol_call == null) {
                @panic("todo");
            }

            // Get and select LHS symbol
            const sym = self.getSymbol(lhs_info.symbol_call.?).?;

            var can_access_field = false;
            if (sym.data == parser.SymbolTag.Variable) {
                var class_name = switch (sym.data.Variable.data_type.data) {
                    .VariableCall => |var_call| var_call.name,
                    .PointerCall => |ptr_call| blk: {
                        // lhs_info.position.errorMessageReturn("", .{});
                        // sym.data.Variable.data_type.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                        break :blk ptr_call.node.data.VariableCall.name;
                    }, // TODO: Change to allow multi ptr and generic ptr.
                    .GenericCall => @panic("todo"),
                    else => unreachable
                };

                if (self.getAlias(class_name)) |sym_alias| {
                    class_name = sym_alias.data.TypeAlias.value;
                } 

                if (self.getClass(class_name)) |sym_class| {
                    self.scope.entered = sym_class;
                } else {
                    lhs_info.position.errorMessageReturn("", .{});
                    gen_lhs.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                    std.log.info("Could not get class {s}", .{class_name});
                    @panic("todo");
                }

                can_access_field = true;
            } else {
                self.scope.entered = sym;
            }

            // Generate RHS
            const gen_rhs = self.generateNode(node.data.BinaryOperation.rhs.*);
            const rhs_info = self.getInfo(gen_rhs.id).?;

            // Check if can access self
            if (rhs_info.symbol_call) |sym_call_id| {
                const sym_call = self.getSymbol(sym_call_id).?;
                if (sym_call.data == parser.SymbolTag.Variable) {
                    if (!can_access_field) {
                        // Cannot access field
                        @panic("todo");
                    }
                } else if (sym_call.data == parser.SymbolTag.Function) {
                    if (!sym_call.data.Function.constructor) {
                        if (!can_access_field) {
                            // Cannot access methods
                            @panic("todo");
                        }
                    }
                }
            }

            // Generate type info
            const info = self.getInfo(node.id).?;
            info.data_type = rhs_info.data_type;

            // Generate symbol link
            info.symbol_call = rhs_info.symbol_call;

            new_node.data.BinaryOperation.lhs.* = gen_lhs;
            new_node.data.BinaryOperation.rhs.* = gen_rhs;

            self.scope.entered = null;
        } else if (node.data.BinaryOperation.operator == parser.Operator.Assignment) {
            // Generate LHS
            const gen_lhs = self.generateNode(node.data.BinaryOperation.lhs.*);
            const lhs_info = self.getInfo(gen_lhs.id).?;

            if (lhs_info.symbol_call == null) {
                @panic("todo");
            }

            // Get symbol
            const symbol = self.getSymbol(lhs_info.symbol_call.?).?;

            // Check if can be modified
            if (symbol.data.Variable.constant and symbol.data.Variable.initialized) {
                symbol.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                // @panic("todo");
            }

            // Generate RHS
            const gen_rhs = self.generateNode(node.data.BinaryOperation.rhs.*);
            const rhs_info = self.getInfo(gen_rhs.id).?;

            // Check type
            if (rhs_info.data_type) |data_type| {
                _ = data_type;
                // TODO: Check data type
                // if (!std.mem.eql(u8, data_type, symbol.data.Variable.data_type)) {
                //     @panic("todo");
                // }
            } else {
                @panic("todo");
            }

            // Update symbol
            symbol.data.Variable.initialized = true;

            new_node.data.BinaryOperation.lhs.* = gen_lhs;
            new_node.data.BinaryOperation.rhs.* = gen_rhs;
        } else if (node.data.BinaryOperation.operator == parser.Operator.To) {
            // Generate LHS
            const gen_lhs = self.generateNode(node.data.BinaryOperation.lhs.*);
            const lhs_info = self.getInfo(gen_lhs.id).?;


            if (lhs_info.symbol_call == null) {
                @panic("todo");
            }

            // Get cast function name
            const sym = self.getSymbol(lhs_info.symbol_call.?).?;
            var class_name = switch (sym.data.Variable.data_type.data) {
                .VariableCall => |var_call| var_call.name,
                .PointerCall => |ptr_call| blk: {
                    // lhs_info.position.errorMessageReturn("", .{});
                    // sym.data.Variable.data_type.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                    break :blk ptr_call.node.data.VariableCall.name;
                }, // TODO: Change to allow multi ptr and generic ptr.
                .GenericCall => @panic("todo"),
                else => unreachable
            };

            if (self.getAlias(class_name)) |sym_alias| {
                class_name = sym_alias.data.TypeAlias.value;
            } 

            if (self.getClass(class_name)) |sym_class| {
                var extension_found = false;
                for (sym_class.data.Class.extensions.items) |extension| {
                    if (extension.data == parser.NodeTag.GenericCall) {
                        if (std.mem.eql(u8, extension.data.GenericCall.name, "Cast")) {
                            // Get generic symbol
                            const generic_node: parser.Node = extension.data.GenericCall.parameters.items[0];
                            var generic_name = switch (generic_node.data) {
                                .VariableCall => |var_call| var_call.name,
                                .PointerCall => |ptr_call| ptr_call.node.data.VariableCall.name, // TODO: Change to allow multi ptr and generic ptr.
                                .GenericCall => @panic("todo"),
                                else => unreachable
                            };

                            // Get the symbol for rhs
                            var rhs_name = switch (node.data.BinaryOperation.rhs.data) {
                                .VariableCall => |var_call| var_call.name,
                                .PointerCall => |ptr_call| ptr_call.node.data.VariableCall.name, // TODO: Change to allow multi ptr and generic ptr.
                                .GenericCall => @panic("todo"),
                                else => unreachable
                            };

                            if (std.mem.eql(u8, generic_name, rhs_name)) {
                                extension_found = true;
                            }
                        }
                    }
                }

                if (!extension_found) {
                    @panic("todo");
                }
            } else {
                lhs_info.position.errorMessageReturn("", .{});
                gen_lhs.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
                std.log.info("Could not get class {s}", .{class_name});
                @panic("todo");
            }

            const fun_name = std.mem.concat(self.allocator, u8, &[_][]const u8 {
                class_name,
                "_cast_Cast_",
                utils.process_node_name(self.allocator, node.data.BinaryOperation.rhs.*)
            }) catch unreachable;

            var fun_params = parser.NodeList.init(self.allocator);
            var inner = self.allocator.create(parser.Node) catch unreachable;
            inner.* = gen_lhs;
            fun_params.append(parser.Node.gen(parser.NodeData {
                .CI_PreC = parser.CI_PreCNode {
                    .code = "&",
                    .node = inner
                }
            })) catch unreachable;

            new_node.data = parser.NodeData {
                .FunctionCall = parser.FunctionCallNode {
                    .name = fun_name,
                    .parameters = fun_params
                }
            };

            const info = self.getInfo(node.id).?;
            info.data_type = node.data.BinaryOperation.rhs;
            info.no_check = true;
        }   
        
        return new_node;
    }

    fn generateUnaryOperation(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check if value type is compatible with unary
        // TODO: Generate type info
        // TODO: Check scope (possible here)

        var new_node = node;
        const info = self.getInfo(node.id).?;

        if (node.data.UnaryOperation.operator == parser.Operator.Deref) {
            const gen_value = self.generateNode(node.data.UnaryOperation.value.*);
            const gen_info = self.getInfo(gen_value.id).?;

            if (gen_info.data_type) |data_type| {
                if (data_type.data != parser.NodeTag.PointerCall) {
                    @panic("todo");
                } 
                
                new_node.data.UnaryOperation.value.* = gen_value;
                info.data_type = data_type.data.PointerCall.node;
            } else {
                @panic("todo");
            }
        }
        
        return new_node;
    }

    fn generateIf(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check conditions are c_int 
        // TODO: Check body 
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
    }

    fn generateWhile(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check conditions is c_int 
        // TODO: Check body 
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
    }

    fn generateLabel(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check doesn't already exists
        // TODO: Keep track of it to add it before and after (and for other labels check)
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
    }

    fn generateContinue(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check scope (possible here)
        // TODO: Check if label exists

        _ = self;
        
        return node;
    }

    fn generateBreak(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check scope (possible here)
        // TODO: Check if label exists

        _ = self;
        
        return node;
    }

    fn generateMatch(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check conditions are c_int 
        // TODO: Check body 
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
    }

    fn generateClass(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsClassDefinition()) {
            @panic("todo");
        }

        // Clone node to be able to modify it while keeping the previous values
        var new_node = node;

        // Enter scope
        const infos = self.getInfo(node.id).?;
        const sym = self.getSymbol(infos.symbol_def.?).?;
        const scope = Scope {
            .parent = self.allocator.create(Scope) catch unreachable,
            .scope = sym
        };
        scope.parent.?.* = self.scope;
        self.scope = scope;

        // Check body
        var body = parser.NodeList.init(self.allocator);
        for (node.data.Class.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
        }
        new_node.data.Class.body = body;
        
        // Exit scope
        self.scope = self.scope.parent.?.*;
        
        return new_node;
    }

    fn generateExtend(self: *Generator, node: parser.Node) parser.Node {
        // Check if possible
        if (!self.scope.acceptsClassDefinition()) {
            @panic("todo");
        }

        // TODO: Check if all functions are present (and only the defined one, no extra)

        var new_node = node;

        const info = self.getInfo(node.id).?;

        // Get matching class
        const class_name = if (self.getAlias(node.data.ExtendStatement.name)) |alias| alias.data.TypeAlias.value else node.data.ExtendStatement.name;

        const class_sym = self.getClass(class_name) orelse {
            @panic("todo");
        };

        if (class_sym.data.Class.sealed) {
            info.position.errorMessageReturnOneLine("Cannot extend sealed class!", .{});
            const class_info = self.getInfo(class_sym.node_id).?;
            class_info.position.errorMessageOneLine("Defined here:", .{});
        }

        if (node.data.ExtendStatement.with) |with| {
            class_sym.data.Class.extensions.append(with.*) catch unreachable;
        }

        // Move symbols
        class_sym.data.Class.children.appendSlice(info.aside_symbols.?.items) catch unreachable;

        // Enter class scope
        const scope = Scope {
            .parent = self.allocator.create(Scope) catch unreachable,
            .scope = class_sym
        };
        scope.parent.?.* = self.scope;
        self.scope = scope;

        // Check body
        var body = parser.NodeList.init(self.allocator);
        for (node.data.ExtendStatement.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
        }
        new_node.data.ExtendStatement.body = body;
        
        // Exit scope
        self.scope = self.scope.parent.?.*;
                
        return new_node;
    }

    fn generateInterface(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsClassDefinition()) {
            @panic("todo");
        }

        // Clone node to be able to modify it while keeping the previous values
        var new_node = node;

        // Enter scope
        const infos = self.getInfo(node.id).?;
        const sym = self.getSymbol(infos.symbol_def.?).?;
        const scope = Scope {
            .parent = self.allocator.create(Scope) catch unreachable,
            .scope = sym
        };
        scope.parent.?.* = self.scope;
        self.scope = scope;

        // Check body
        var body = parser.NodeList.init(self.allocator);
        for (node.data.Interface.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
        }
        new_node.data.Interface.body = body;
        
        // Exit scope
        self.scope = self.scope.parent.?.*;
        
        return new_node;
    }

    fn generatePrototype(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsClassDefinition()) {
            @panic("todo");
        }

        // Clone node to be able to modify it while keeping the previous values
        var new_node = node;

        // Enter scope
        const infos = self.getInfo(node.id).?;
        const sym = self.getSymbol(infos.symbol_def.?).?;
        const scope = Scope {
            .parent = self.allocator.create(Scope) catch unreachable,
            .scope = sym
        };
        scope.parent.?.* = self.scope;
        self.scope = scope;

        // Check body
        var body = parser.NodeList.init(self.allocator);
        for (node.data.Prototype.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
        }
        new_node.data.Prototype.body = body;
        
        // Exit scope
        self.scope = self.scope.parent.?.*;
        
        return new_node;
    }

    fn generateNode(self: *Generator, node: parser.Node) parser.Node {
        switch (node.data) {
            .Value => return self.generateValue(node),
            .FunctionDefinition => return self.generateFunctionDefinition(node),
            .FunctionCall => return self.generateFunctionCall(node),
            .Use => return self.generateUse(node),
            .Return => return self.generateReturn(node),
            .VariableDefinition => return self.generateVariableDefinition(node),
            .VariableCall => return self.generateVariableCall(node),
            .BinaryOperation => return self.generateBinaryOperation(node),
            .UnaryOperation => return self.generateUnaryOperation(node),
            .If => return self.generateIf(node),
            .While => return self.generateWhile(node),
            .Label => return self.generateLabel(node),
            .Continue => return self.generateContinue(node),
            .Break => return self.generateBreak(node),
            .Match => return self.generateMatch(node),
            .Class => return self.generateClass(node),
            .ExtendStatement => return self.generateExtend(node),
            .Interface => return self.generateInterface(node),
            .Prototype => return self.generatePrototype(node),
            .PointerCall => unreachable,
            else => return node
        }
    }

    fn generateDefaultTypes(self: *Generator) void {
        self.symbols.append(parser.Symbol.gen(parser.SymbolData {
            .Class = parser.ClassSymbol {
                .name = "c_int",
                .extensions = std.ArrayList(parser.Node).init(self.allocator),
                .children = parser.SymbolList.init(self.allocator),
                .sealed = false,
            }
        }, parser.Node.NO_ID)) catch unreachable;
    }

    pub fn generate(self: *Generator) struct { parser.NodeList, parser.NodeInfos, parser.SymbolList } {
        self.generateDefaultTypes();
        
        var ast = parser.NodeList.init(self.allocator);

        while(self.getCurrent()) |current| {
            ast.append(self.generateNode(current)) catch unreachable;
            self.advance();
        }
        
        return . { ast, self.infos, self.symbols };
    }
    
};