const std = @import("std");
const help = @import("../helper.zig");

pub fn two(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator(",", "2", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}


fn partOne(entryItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var count:usize = 0;
    while(entryItr.next())|entry|{
        var tokenizer = std.mem.tokenizeSequence(u8, entry, "-");
        const start = try getValue(tokenizer.next());
        const end = try getValue(tokenizer.next());
        count += try getWrongIdCountInRangePart1(start, end, common.alloc);
    }
    std.log.info("{d}", .{count});
}

fn partTwo(entryItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var count:usize = 0;
    while(entryItr.next())|entry|{
        var tokenizer = std.mem.tokenizeSequence(u8, entry, "-");
        const start = try getValue(tokenizer.next());
        const end = try getValue(tokenizer.next());
        count += try getWrongIdCountInRangePart2(start, end, common.alloc);
    }
    std.log.info("{d}", .{count});
}

fn getWrongIdCountInRangePart2(start:usize, end:usize, alloc:std.mem.Allocator)!usize{
    var count:usize = 0;
    std.log.debug("{d}-{d}", .{start, end});
    for(start..end+1)|id|{
        const string = try std.fmt.allocPrint(alloc,"{d}", .{id});
        defer alloc.free(string);

        var seqLength = string.len/2;
        while(seqLength > 0) : (seqLength -= 1){
            //check the pattern
            if(string.len % seqLength != 0)
                continue;

            const checkCount = string.len/seqLength;
            var pattern = true;
            for(1..checkCount)|expand|{
                if(!std.mem.eql(u8, string[0..seqLength], string[seqLength*expand..seqLength*(expand+1)])){
                    pattern = false;
                    break;
                }
            }

            if(!pattern)
                continue;

            std.log.info("found:{s}", .{string});
            count += id;
            break;
        }
    }
    return count; 
}

fn getWrongIdCountInRangePart1(start:usize, end:usize, alloc:std.mem.Allocator)!usize{
    var count:usize = 0;
    std.log.debug("{d}-{d}", .{start, end});
    for(start..end+1)|id|{
        const string = try std.fmt.allocPrint(alloc,"{d}", .{id});
        defer alloc.free(string);

        const half = string.len/2;

        if(!std.mem.eql(u8, string[0..half], string[half..string.len]))
            continue;

        std.log.info("found:{s}", .{string});
        count += id;
    }
    return count; 
}

fn getValue(token:?[]const u8) !usize{
    if(token)|string|{
        //the parse int failes on the last line
        var value:usize = 0; 
        if(string[string.len-1] == '\n'){
            value = try std.fmt.parseInt(usize, string[0..string.len-1], 10);
        }
        else{
            value = try std.fmt.parseInt(usize, string, 10);
        }
        return value;
    }
    std.log.err("Failed to parse token:{any}", .{token});
    return CustomError.FailedPars;
}

const CustomError = error{
    FailedPars
};


