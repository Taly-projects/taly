const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const translator = @import("translator.zig");
const generator = @import("generator.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    const stdout = std.io.getStdOut();        

    // Create Output Dir
    try std.fs.cwd().deleteTree("out");
    try std.fs.cwd().makeDir("out");
    var out_dir = try std.fs.cwd().openDir("out", .{});
    defer out_dir.close();

    // Read Source
    var file = try std.fs.cwd().openFile("main.taly", .{});
    const file_size = (try file.stat()).size;
    var src = try arena.allocator().alloc(u8, file_size);
    try file.reader().readNoEof(src);

    stdout.writeAll("### Lexer ###\n") catch unreachable;

    var lex = lexer.Lexer.init(src);
    const tokens = lex.tokenize(arena.allocator());

    for (tokens.items) |token| {
        std.log.info("{}", .{token});
    }

    var par = parser.Parser.init(tokens, arena.allocator());
    const ast = par.parse();

    // Create Output File
    var parser_out = try out_dir.createFile("parser.xml", .{});
    defer parser_out.close();

    for (ast.items) |node| {
        node.writeXML(parser_out.writer(), 0) catch unreachable;
    }

    // Generator
    var gen = generator.Generator.init(ast, arena.allocator());
    const gen_ast = gen.generate();

    // Create Output File
    var generator_out = try out_dir.createFile("generator.xml", .{});
    defer generator_out.close();

    for (gen_ast.items) |node| {
        node.writeXML(generator_out.writer(), 0) catch unreachable;
    }
    
    // Translator
    var tra = translator.Translator.init(gen_ast, arena.allocator());
    const c_ast = tra.translate();

    // Create Output File
    var translator_out = try out_dir.createFile("translator.xml", .{});
    defer translator_out.close();
    
    for (c_ast.items) |node| {
        node.writeXML(translator_out.writer(), 0) catch unreachable;
    }

    // Create Output File
    var c_out = try out_dir.createFile("main.c", .{});
    defer c_out.close();

    for (c_ast.items) |node| {
        if (node.writeC(c_out.writer(), 0) catch unreachable) {
            c_out.writeAll(";") catch unreachable;
        }
        c_out.writeAll("\n") catch unreachable;
    }
}