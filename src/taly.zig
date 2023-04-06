const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const generator = @import("generator.zig");
const translator = @import("translator.zig");

pub const Dependencies = std.ArrayList(CompilerData);
pub var dependencies: ?Dependencies = null;

pub const CompilerData = struct {
    name: []const u8,
    path: []const u8,
    src: []const u8,
    tokens: ?lexer.TokenList,
    ast: ?parser.NodeList,
    node_infos: ?parser.NodeInfos,
    symbols: ?parser.SymbolList,
    out: ?translator.File,

    pub fn get(name: []const u8) ?*CompilerData {
        if (dependencies == null) return null;
        for (dependencies.?.items) |*item| {
            if (std.mem.eql(u8, name, item.name)) return item;
        }
        return null;
    }

    pub fn compile(allocator: std.mem.Allocator, path: []const u8) !*CompilerData {
        // Get name from path
        const index = std.mem.lastIndexOf(u8, path, "/") orelse 0;
        const last_index = std.mem.lastIndexOf(u8, path, ".") orelse path.len - 1;
        const name = path[index..last_index];

        // Check if exists 
        if (get(name)) |x| return x;
        
        // Initialize the allocator
        if (dependencies == null) {
            dependencies = Dependencies.init(allocator);
        }

        // Read source
        var file = try std.fs.cwd().openFile(path, .{});
        const file_size = (try file.stat()).size;
        var src = try allocator.alloc(u8, file_size);
        try file.reader().readNoEof(src);

        const data = CompilerData {
            .name = name,
            .path = path,
            .src = src,
            .tokens = null,
            .ast = null,
            .node_infos = null,
            .symbols = null,
            .out = null
        };

        dependencies.?.append(data) catch unreachable;

        const ref = &dependencies.?.items[dependencies.?.items.len - 1];

        // Lexer
        var lex = lexer.Lexer.init(name, src);
        const tokens = lex.tokenize(allocator);

        ref.tokens = tokens;

        // Parser
        var par = parser.Parser.init(path, src, tokens, allocator);
        const par_res = par.parse();
        const par_ast = par_res.@"0";
        const par_infos = par_res.@"1";
        const par_symbols = par_res.@"2";

        // Generator
        var gen = generator.Generator.init(path, src, par_ast, par_infos, par_symbols, allocator);
        const gen_res = gen.generate();
        const gen_ast = gen_res.@"0";
        const gen_infos = gen_res.@"1";
        const gen_symbols = gen_res.@"2";

        ref.ast = gen_ast;
        ref.node_infos = gen_infos;
        ref.symbols = gen_symbols;

        // Translator
        var tra = translator.Translator.init(gen_ast, gen_infos, gen_symbols, allocator);
        const tra_out = tra.translate(name);

        ref.out = tra_out;

        return ref;
    }

};

pub fn generate(allocator: std.mem.Allocator, out_dir: std.fs.Dir) !void {
    for (dependencies.?.items) |dependencie| {
        var file_source_name = allocator.alloc(u8, dependencie.name.len + 2) catch unreachable;
        std.mem.copy(u8, file_source_name, dependencie.name);
        file_source_name[dependencie.name.len] = '.';
        file_source_name[dependencie.name.len + 1] = 'c';

        var file_header_name = allocator.alloc(u8, dependencie.name.len + 2) catch unreachable;
        std.mem.copy(u8, file_header_name, dependencie.name);
        file_header_name[dependencie.name.len] = '.';
        file_header_name[dependencie.name.len + 1] = 'h';


        var c_out = try out_dir.createFile(file_source_name, .{});

        for (dependencie.out.?.source.items) |node| {
            if (node.writeC(c_out.writer(), 0) catch unreachable) {
                c_out.writeAll(";") catch unreachable;
            }
            c_out.writeAll("\n") catch unreachable;
        }

        c_out.close();

        var h_out = try out_dir.createFile(file_header_name, .{});
        defer h_out.close();

        for (dependencie.out.?.header.items) |node| {
            if (node.writeC(h_out.writer(), 0) catch unreachable) {
                h_out.writeAll(";") catch unreachable;
            }
            h_out.writeAll("\n") catch unreachable;
        }
    }
}

pub fn generateAst(allocator: std.mem.Allocator, out_dir: std.fs.Dir) !void {
    for (dependencies.?.items) |dependency| {
        var path = try std.mem.concat(allocator, u8, &[_][]const u8 {dependency.name, "_ast.xml"});

        var file = try out_dir.createFile(path, .{});
        for (dependency.ast.?.items) |node| {
            try node.writeXML(file.writer(), 0);
        }

        file.close();
        path = try std.mem.concat(allocator, u8, &[_][]const u8 {dependency.name, "_infos.xml"});

        file = try out_dir.createFile(path, .{});
        for (dependency.node_infos.?.items) |info| {
            try info.writeXML(file.writer());
        }

        file.close();
        path = try std.mem.concat(allocator, u8, &[_][]const u8 {dependency.name, "_symbols.xml"});

        file = try out_dir.createFile(path, .{});
        for (dependency.symbols.?.items) |sym| {
            try sym.writeXML(file.writer(), 0);
        }
    }
    
}

pub fn run(allocator: std.mem.Allocator, out_dir: []const u8) !void {
    var list = std.ArrayList([]const u8).init(allocator);
    try list.append("gcc");
    for (dependencies.?.items) |dependencie| {
        try list.append(try std.mem.concat(allocator, u8, &[_][]const u8{out_dir, dependencie.name, ".c"}));
    }
    try list.append("-o");
    try list.append("out/main");

    const arg = list.items;

    // const arg = [_][]const u8 {"gcc", "out/main.c", "-o", "out/main"};
    var child_process = std.ChildProcess.init(arg, allocator);
    var buffer = allocator.alloc(u8, 248) catch unreachable;
    child_process.cwd = try std.os.getcwd(buffer);
    _ = try child_process.spawnAndWait();

    const arg2 = [_][]const u8 {"out/main"};
    child_process.argv = &arg2;
    _ = try child_process.spawnAndWait();
}