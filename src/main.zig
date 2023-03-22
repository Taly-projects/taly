const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const translator = @import("translator.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    const stdout = std.io.getStdOut();        

    stdout.writeAll("### Lexer ###\n") catch unreachable;

    var lex = lexer.Lexer.init("extern fn printf(msg: c_string)\n\nfn main() => \n\tprintln(\"Hello, world!\")");
    // var lex = lexer.Lexer.init("println(\"Hello, world\")");
    const tokens = lex.tokenize(arena.allocator());

    for (tokens.items) |token| {
        std.log.info("{}", .{token});
    }

    stdout.writeAll("\n\n### Parser ###\n") catch unreachable;

    var par = parser.Parser.init(tokens, arena.allocator());
    const ast = par.parse();
    for (ast.items) |node| {
        node.writeXML(stdout.writer(), 0) catch unreachable;
    }

    stdout.writeAll("\n\n### Translator ###\n") catch unreachable;

    var tra = translator.Translator.init(ast, arena.allocator());
    const c_ast = tra.translate();
    
    for (c_ast.items) |node| {
        node.writeXML(stdout.writer(), 0) catch unreachable;
    }

    stdout.writeAll("\n\n### Generated (C) ###\n") catch unreachable;

    for (c_ast.items) |node| {
        if (node.writeC(stdout.writer(), 0) catch unreachable) {
            stdout.writeAll(";") catch unreachable;
        }
        stdout.writeAll("\n") catch unreachable;
    }
}