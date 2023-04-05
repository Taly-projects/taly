const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const translator = @import("translator.zig");
const generator = @import("generator.zig");
const taly = @import("taly.zig");

// Run command:
// clear && zig build run -freference-trace -- main.taly --ast --run

pub fn main() !void {
    const stdout = std.io.getStdOut();
    if (std.os.argv.len <= 1) {
        try stdout.writeAll("No file specified! use -h or --help to see all the commands.\n");
        return;
    } 

    const path = std.mem.span(std.os.argv[1]);
    var print_ast: bool = false;
    var run: bool = false;

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
            try stdout.writeAll("\t--run\t\t\t\t\t\t\t\tRun the compilated program (using gcc)\n");
            return;
        } else if (std.mem.eql(u8, arg, "--ast")) {
            print_ast = true;
        } else if (std.mem.eql(u8, arg, "--run")) {
            run = true;
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

    _ = try taly.CompilerData.compile(arena.allocator(), path);

    try taly.generate(arena.allocator(), out_dir);

    if (run) {
        try taly.run(arena.allocator(), "out/");
    }

    // // Read Source
    // var file = try std.fs.cwd().openFile(path, .{});
    // const file_size = (try file.stat()).size;
    // var src = try arena.allocator().alloc(u8, file_size);
    // try file.reader().readNoEof(src);

    // var lex = lexer.Lexer.init(path, src);
    // const tokens = lex.tokenize(arena.allocator());

    // // for (tokens.items) |token| {
    // //     std.fmt.format(stdout.writer(), "{full}\n", .{token.data}) catch unreachable;
    // // }

    // var par = parser.Parser.init(path, src, tokens, arena.allocator());
    // const par_res = par.parse();
    // const ast = par_res.@"0";
    // const infos = par_res.@"1";
    // const symbols = par_res.@"2";

    // // Generator
    // var gen = generator.Generator.init(path, src, ast, infos, symbols, arena.allocator());
    // const gen_res = gen.generate();
    // const gen_ast = gen_res.@"0";
    // const gen_infos = gen_res.@"1";
    // const gen_symbols = gen_res.@"2";

    // if (print_ast) {
    //     // Create Output File
    //     var ast_out = try out_dir.createFile("ast.xml", .{});
    //     defer ast_out.close();

    //     for (gen_ast.items) |node| {
    //         node.writeXML(ast_out.writer(), 0) catch unreachable;
    //     }
    //     // Create Output File
    //     var infos_out = try out_dir.createFile("infos.xml", .{});
    //     defer infos_out.close();

    //     for (gen_infos.items) |info| {
    //         info.writeXML(infos_out.writer()) catch unreachable;
    //     }
    //     // Create Output File
    //     var symbols_out = try out_dir.createFile("symbols.xml", .{});
    //     defer symbols_out.close();

    //     for (gen_symbols.items) |sym| {
    //         sym.writeXML(symbols_out.writer(), 0) catch unreachable;
    //     }
    // }
    
    // // Translator
    // var tra = translator.Translator.init(gen_ast, gen_infos, gen_symbols, arena.allocator());
    // const c_project = tra.translate();

    // for (c_project.files.items) |c_file| {
    //     var file_source_name = arena.allocator().alloc(u8, c_file.name.len + 2) catch unreachable;
    //     std.mem.copy(u8, file_source_name, c_file.name);
    //     file_source_name[c_file.name.len] = '.';
    //     file_source_name[c_file.name.len + 1] = 'c';

    //     var file_header_name = arena.allocator().alloc(u8, c_file.name.len + 2) catch unreachable;
    //     std.mem.copy(u8, file_header_name, c_file.name);
    //     file_header_name[c_file.name.len] = '.';
    //     file_header_name[c_file.name.len + 1] = 'h';


    //     var c_out = try out_dir.createFile(file_source_name, .{});

    //     for (c_file.source.items) |node| {
    //         if (node.writeC(c_out.writer(), 0) catch unreachable) {
    //             c_out.writeAll(";") catch unreachable;
    //         }
    //         c_out.writeAll("\n") catch unreachable;
    //     }

    //     c_out.close();

    //     var h_out = try out_dir.createFile(file_header_name, .{});
    //     defer h_out.close();

    //     for (c_file.header.items) |node| {
    //         if (node.writeC(h_out.writer(), 0) catch unreachable) {
    //             h_out.writeAll(";") catch unreachable;
    //         }
    //         h_out.writeAll("\n") catch unreachable;
    //     }
        
    // }


    // if (run) {
    //     const arg = [_][]const u8 {"gcc", "out/main.c", "-o", "out/main"};
    //     var child_process = std.ChildProcess.init(&arg, arena.allocator());
    //     var buffer = arena.allocator().alloc(u8, 248) catch unreachable;
    //     child_process.cwd = try std.os.getcwd(buffer);
    //     _ = try child_process.spawnAndWait();

    //     const arg2 = [_][]const u8 {"out/main"};
    //     child_process.argv = &arg2;
    //     _ = try child_process.spawnAndWait();
    // } else {
    //     try stdout.writeAll("Compilation successfull!\n");
    // }
}