const std = @import("std");
const days = @import("days.zig");
const help = @import("helper.zig");

pub fn main(init:std.process.Init)!void{
    var args_iter = try init.minimal.args.iterateAllocator(init.gpa);
    defer args_iter.deinit();

    //The first argument is the executable path.
    _ = args_iter.next();

    //ask if example or real
    const io = init.io;
    var buffer:[1024]u8 = undefined;

    var writer = std.Io.File.stdout().writer(io, &buffer);
    var reader = std.Io.File.stdin().reader(io, &buffer);

    const stdout = &writer.interface;
    const stdin = &reader.interface;

    //todo read userInput
    const useExample = try askYesOrNo(stdout, stdin, "Use example"); 
    const taskOne = try askYesOrNo(stdout, stdin, "Run task one");

    const commons = help.CommonWrapper{
        .useExample = useExample,
        .runTaskOne = taskOne,
        .io = io,
        .alloc = init.arena.allocator()
    };

    if(args_iter.next())|dayArg|{
        switch(getDay(dayArg)){
            1 => try days.one(commons),
            2 => try days.two(commons), 
            3 => try days.three(commons),
            4 => try days.four(commons),
            5 => try days.five(commons),
            6 => try days.six(commons),
            7 => try days.seven(commons),
            8 => try days.eight(commons),
            9 => try days.nine(commons),
            10 => try days.ten(commons),
            else => return
        }
    }
}

fn askYesOrNo(stdout:*std.Io.Writer, stdin:*std.Io.Reader, comptime question:[]const u8)!bool{
    while(true){
        try stdout.print("{s}? y/n\n", .{question});
        try stdout.flush();

        const answer = try stdin.takeDelimiterExclusive('\n');
        //keeps the \n byte in the stream therefore needs to toss
        stdin.toss(1);
        if(std.mem.eql(u8, answer, "y")){
            return true;
        }
        else if(std.mem.eql(u8, answer, "n")){
            return false;
        }
        std.log.debug("Input:{s}", .{stdin.buffer});
    }
}

fn getDay(arg:[]const u8) u8{
   const parsed = std.fmt.parseInt(u8, arg, 10) catch |err|{
       std.log.debug("Failed to convert:{s} to int, {}", .{arg, err});
       return 0;
   };
   return parsed;
}

fn iterArguments(init: *std.process.Init)void{    
    var args_iter = try init.minimal.args.iterateAllocator(init.gpa);
    defer args_iter.deinit();

    //first argument is the executable path
    while(args_iter.next())|arg|{
        std.debug.log("{}", .{arg});
    } 
}
