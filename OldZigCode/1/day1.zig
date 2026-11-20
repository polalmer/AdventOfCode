const std = @import("std");
const help = @import("../helper.zig");

pub fn one(common: help.CommonWrapper) !void{
    var lineItr = try help.getFileIterator("\n", "1", &common);
    if(common.runTaskOne) try taskOne(&lineItr) else try taskTwo(&lineItr);
}

fn taskOne(lineItr:*help.StrIterator)!void{
    var countOnZero:usize = 0;
    var pos:usize = 50;
    while(lineItr.next())|line|{
        const isLeft = line[0] == 'L';
        var clicks = try std.fmt.parseInt(usize, line[1..], 10);
        while(clicks > 0){
            if(isLeft){
                pos = if (pos == 0) 99 else pos - 1;
            }
            else{
                pos = if (pos == 99) 0 else pos + 1;
            }
            
            clicks -= 1;
        }
        if(pos == 0) countOnZero += 1;
    }
    std.log.info("{}", .{countOnZero});
}

fn taskTwo(lineItr:*help.StrIterator)!void{
    var countOnZero:usize = 0;
    var pos:usize = 50;
    while(lineItr.next())|line|{
        const isLeft = line[0] == 'L';
        var clicks = try std.fmt.parseInt(usize, line[1..], 10);
        while(clicks > 0){
            if(isLeft){
                pos = if (pos == 0) 99 else pos - 1;
            }
            else{
                pos = if (pos == 99) 0 else pos + 1;
            }
            
            clicks -= 1;
            if(pos == 0) countOnZero += 1;
        }
    }
    std.log.info("{}", .{countOnZero});
}
