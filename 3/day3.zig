const std = @import("std");
const help = @import("../helper.zig");

pub fn three(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "3", &common);
    if(common.runTaskOne){
        try partOne(&itr);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partTwo(entryItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    var combined:usize = 0;
    while(entryItr.next())|bank|{
       combined += try find12DigitJoltage(bank, common.alloc);
    }
    std.log.info("{d}", .{combined});
}

fn find12DigitJoltage(bank:[]const u8, alloc: std.mem.Allocator) !usize{
    std.log.debug("{s}", .{bank});

    const joltString = try alloc.alloc(u8, 12);
    var joltIndicies:[12]usize = .{0,1,2,3,4,5,6,7,8,9,10,11};
    defer alloc.free(joltString);
    std.mem.copyForwards(u8, joltString, bank[0..12]);

    var digitPos:usize = 1;
    while(digitPos < bank.len) : (digitPos += 1){
        for(0..joltString.len)|joltIndex|{
            if(joltIndicies[joltIndex] > digitPos) 
                break;
            if(bank[digitPos] <= joltString[joltIndex])
                continue;
            //check if rest of bank fits into joltString
            const rest = joltString.len-joltIndex;
            if(digitPos + rest > bank.len)
                continue;
            std.mem.copyForwards(u8, joltString[joltIndex..joltIndex+rest], bank[digitPos..digitPos+rest]);
            var next:usize = 0;
            for(joltIndex..joltIndex+rest)|changeIndex|{
                joltIndicies[changeIndex] = digitPos + next;
                next += 1;
            }
            break;
        }
    }
    const joltage = try std.fmt.parseInt(usize, joltString, 10);
    for(joltIndicies)|index|{
        std.log.debug("Indices:{d}", .{index});
    }
    std.log.debug("{d}", .{joltage});
    return joltage;
}

fn partOne(entryItr:*help.StrIterator) !void{
    var combined:usize = 0;
    while(entryItr.next())|bank|{
        combined += try findJoltage(bank);
    }
    std.log.info("{d}", .{combined});
}

fn findJoltage(bank:[]const u8) !usize{
    std.log.debug("{s}", .{bank});
    var posOne:usize = 0;
    var posTwo:usize = 1;

    var digitPos:usize = 1;
    while(digitPos < bank.len) : (digitPos += 1){
        if(bank[digitPos] > bank[posOne]){
            if(digitPos + 1 < bank.len){
                posOne = digitPos;
                posTwo = digitPos + 1;
                continue;
            }
        }
        if(bank[digitPos] > bank[posTwo]){
            posTwo = digitPos;
        }
    }
    const string:[2]u8 = .{bank[posOne], bank[posTwo]};
    const joltage = try std.fmt.parseInt(usize, &string, 10);
    std.log.debug("{d}", .{joltage});
    return joltage;
}


