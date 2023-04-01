const std = @import("std");
const position = @import("position.zig");
const parser = @import("parser.zig");

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
                .Function, .Block, .Class => return true,
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
                .Class => return true,
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
            _ = entered;
            // TODO: manage enetered
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
};

pub const Generator = struct {
    allocator: std.mem.Allocator,
    ast: parser.NodeList,
    infos: parser.NodeInfos,
    symbols: parser.SymbolList,
    scope: Scope = Scope{},
    index: usize = 0,

    pub fn init(ast: parser.NodeList, infos: parser.NodeInfos, symbols: parser.SymbolList, allocator: std.mem.Allocator) Generator {
        return Generator {
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
        // Check if possible
        if (!self.scope.acceptsStatement()) {
            @panic("todo");
        }

        const info = self.getInfo(node.id).?;
        
        // Genreate type info
        switch (node.data.Value) {
            .String => info.data_type = "c_string",
            .Int => info.data_type = "c_int",
            .Float => info.data_type = "c_float",
            .Bool => info.data_type = "bool",
        }

        return node;
    }

    fn generateFunctionDefinition(self: *Generator, node: parser.Node) parser.Node {
        // Check if possible
        if (!self.scope.acceptsFunctionDefinition()) {
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

        // Contains the new node
        var body = parser.NodeList.init(self.allocator);

        // Check if method
        var parameters = parser.FunctionDefinitionParameters.init(self.allocator);
        if (self.scope.getParentClass()) |class| {
            // Add self parameter
            parameters.append(parser.FunctionDefinitionParameter {
                .name = "self",
                .data_type = std.mem.concat(self.allocator, u8, &[_][]const u8{class.data.Class.name, "*"}) catch unreachable
            }) catch unreachable;

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
            }
        }
        parameters.appendSlice(node.data.FunctionDefinition.parameters.items) catch unreachable;

        // Create symbols for parameters
        for (parameters.items) |param| {
            self.addSymbol(parser.Symbol.gen(parser.SymbolData {
                .Variable = parser.VariableSymbol {
                    .name = param.name,
                    .data_type = param.data_type,
                    .constant = true,
                    .initialized = true
                }
            }, parser.Node.NO_ID));
        }

        // Check body
        for (node.data.FunctionDefinition.body.items) |child| {
            body.append(self.generateNode(child)) catch unreachable;
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
            @panic("todo");
        };

        // Check if parameters match (type + number)
        const specified_param_count = node.data.FunctionCall.parameters.items.len;
        const defined_param_count = function_symbol.data.Function.parameters.items.len;
        if (specified_param_count > defined_param_count) {
            @panic("todo");
        } else if (specified_param_count < defined_param_count) {
            @panic("todo");
        } else {

        }

        var parameters = parser.NodeList.init(self.allocator);
        var i: usize = 0;
        for (node.data.FunctionCall.parameters.items) |param| {
            const defined_param = function_symbol.data.Function.parameters.items[i];

            const generated_param = self.generateNode(param);
            parameters.append(generated_param) catch unreachable;

            const param_info = self.getInfo(generated_param.id).?;
            if (param_info.data_type) |data_type| {
                if (!std.mem.eql(u8, defined_param.data_type, data_type)) {
                    @panic("todo");
                }
            } else {
                @panic("todo");
            }

            i += 1;
        }

        // Generate type info for node (based on return type of the function)
        const info = self.getInfo(node.id).?;
        info.data_type = function_symbol.data.Function.return_type;

        // Generate symbol link
        info.symbol_call = function_symbol.id;
        
        return node;
    }

    fn generateReturn(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check value node
        // TODO: Generate type info for node (based on type of value node)
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
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
                if (!std.mem.eql(u8, data_type, node.data.VariableDefinition.data_type)) {
                    @panic("todo");
                }
            } else {
                @panic("todo");
            }
        
            new_node.data.VariableDefinition.value.?.* = gen_value;
        }
        

        // TODO: Check if doesn't already exists
        
        return new_node;
    }

    fn generateVariableCall(self: *Generator, node: parser.Node) parser.Node {
        // Check scope (possible here)
        if (!self.scope.acceptsStatement()) {
            @panic("todo");
        }

        const info = self.getInfo(node.id).?;

        // Check if exists
        var sym: *parser.Symbol = undefined;

        if (self.scope.getVariable(&self.symbols, node.data.VariableCall.name)) |variable| {
            sym = variable;
            info.data_type = sym.data.Variable.data_type;
        } else if (self.scope.getClass(&self.symbols, node.data.VariableCall.name)) |class| {
            sym = class;
        } else {
            std.log.info("Not found: {s} in:", .{node.data.VariableCall.name});
            self.scope.scope.?.writeXML(std.io.getStdOut().writer(), 0) catch unreachable;
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

        // TODO: Only accept field capturing when using self

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
                const class_name = if (std.mem.endsWith(u8, sym.data.Variable.data_type, "*")) blk: {
                    break :blk sym.data.Variable.data_type[0..(sym.data.Variable.data_type.len - 1)];
                } else sym.data.Variable.data_type;

                if (self.getClass(class_name)) |sym_class| {
                    self.scope.entered = sym_class;
                } else {
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
                if (!std.mem.eql(u8, data_type, symbol.data.Variable.data_type)) {
                    @panic("todo");
                }
            } else {
                @panic("todo");
            }

            // Update symbol
            symbol.data.Variable.initialized = true;

            new_node.data.BinaryOperation.lhs.* = gen_lhs;
            new_node.data.BinaryOperation.rhs.* = gen_rhs;
        }
        
        return new_node;
    }

    fn generateUnaryOperation(self: *Generator, node: parser.Node) parser.Node {
        // TODO: Check if value type is compatible with unary
        // TODO: Generate type info
        // TODO: Check scope (possible here)

        _ = self;
        
        return node;
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

    fn generateNode(self: *Generator, node: parser.Node) parser.Node {
        switch (node.data) {
            .Value => return self.generateValue(node),
            .FunctionDefinition => return self.generateFunctionDefinition(node),
            .FunctionCall => return self.generateFunctionCall(node),
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
            else => return node
        }
    }

    pub fn generate(self: *Generator) struct { parser.NodeList, parser.NodeInfos, parser.SymbolList } {
        var ast = parser.NodeList.init(self.allocator);

        while(self.getCurrent()) |current| {
            ast.append(self.generateNode(current)) catch unreachable;
            self.advance();
        }
        
        return . { ast, self.infos, self.symbols };
    }
    
};