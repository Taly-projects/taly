const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lex = lexer.Lexer.init("fn main() => \n\tprintln(\"Hello, world!\")");
    // var lex = lexer.Lexer.init("println(\"Hello, world\")");
    const tokens = lex.tokenize(arena.allocator());

    for (tokens.items) |token| {
        std.log.info("{}", .{token});
    }

    var par = parser.Parser.init(tokens, arena.allocator());
    const ast = par.parse();
    
    const stdout = std.io.getStdOut();        
    for (ast.items) |node| {
        node.writeXML(stdout.writer(), 0) catch unreachable;
        // std.log.info("{}", .{node});
    }
}