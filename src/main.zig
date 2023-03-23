const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const translator = @import("translator.zig");
const generator = @import("generator.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    if (std.os.argv.len <= 1) {
        try stdout.writeAll("No file specified! use -h or --help to see all the commands.\n");
        return;
    } 

    const path = std.mem.span(std.os.argv[1]);
    var print_ast: bool = false;

    var i: usize = 1;
    while (i < std.os.argv.len) : (i += 1) {
        const arg = std.mem.span(std.os.argv[i]);
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try stdout.writeAll("Usage: taly [path] [args]\n");
            try stdout.writeAll("\n");
            try stdout.writeAll("Possible arguments:\n");
            try stdout.writeAll("\t-h or --help\t\t\t\tDisplay usage\n");
            try stdout.writeAll("\t-v or --version\t\t\tPrint the current version\n");
            try stdout.writeAll("\t--ast\t\t\t\t\t\t\t\tCompile and output the ast\n");
            return;
        } else if (std.mem.eql(u8, arg, "--ast")) {
            print_ast = true;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            try stdout.writeAll("Taly 0.2.0-dev\n");
            return;
        }
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    // Create Output Dir
    try std.fs.cwd().deleteTree("out");
    try std.fs.cwd().makeDir("out");
    var out_dir = try std.fs.cwd().openDir("out", .{});
    defer out_dir.close();

    // Read Source
    var file = try std.fs.cwd().openFile(path, .{});
    const file_size = (try file.stat()).size;
    var src = try arena.allocator().alloc(u8, file_size);
    try file.reader().readNoEof(src);

    var lex = lexer.Lexer.init(src);
    const tokens = lex.tokenize(arena.allocator());

    var par = parser.Parser.init(tokens, arena.allocator());
    const ast = par.parse();

    // Generator
    var gen = generator.Generator.init(ast, arena.allocator());
    const gen_ast = gen.generate();

    if (print_ast) {
        // Create Output File
        var generator_out = try out_dir.createFile("generator.xml", .{});
        defer generator_out.close();

        for (gen_ast.items) |node| {
            node.writeXML(generator_out.writer(), 0) catch unreachable;
        }
    }
    
    // Translator
    var tra = translator.Translator.init(gen_ast, arena.allocator());
    const c_project = tra.translate();

    for (c_project.files.items) |c_file| {
        var file_source_name = arena.allocator().alloc(u8, c_file.name.len + 2) catch unreachable;
        std.mem.copy(u8, file_source_name, c_file.name);
        file_source_name[c_file.name.len] = '.';
        file_source_name[c_file.name.len + 1] = 'c';

        var file_header_name = arena.allocator().alloc(u8, c_file.name.len + 2) catch unreachable;
        std.mem.copy(u8, file_header_name, c_file.name);
        file_header_name[c_file.name.len] = '.';
        file_header_name[c_file.name.len + 1] = 'h';


        var c_out = try out_dir.createFile(file_source_name, .{});

        for (c_file.source.items) |node| {
            if (node.writeC(c_out.writer(), 0) catch unreachable) {
                c_out.writeAll(";") catch unreachable;
            }
            c_out.writeAll("\n") catch unreachable;
        }

        c_out.close();

        var h_out = try out_dir.createFile(file_header_name, .{});
        defer h_out.close();

        for (c_file.header.items) |node| {
            if (node.writeC(h_out.writer(), 0) catch unreachable) {
                h_out.writeAll(";") catch unreachable;
            }
            h_out.writeAll("\n") catch unreachable;
        }
        
    }

    // for (c_ast.items) |node| {
    //     if (node.writeC(c_out.writer(), 0) catch unreachable) {
    //         c_out.writeAll(";") catch unreachable;
    //     }
    //     c_out.writeAll("\n") catch unreachable;
    // }
}