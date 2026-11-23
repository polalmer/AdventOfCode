const std = @import("std");
const help = @import("../helper.zig");

const Map = std.ArrayList(std.ArrayList(bool));

pub fn four(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "4", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partOne(entryItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    const map = try readMap(entryItr, common.alloc);
    countAccessableRolls(&map);
}



fn partTwo(entryItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    var map = try readMap(entryItr, common.alloc);
    var count:usize = 0;
    var removedRolls:usize = 1;
    while(removedRolls > 0){
        removedRolls = removeRolls(&map);
        count += removedRolls;
    }
    std.log.info("Total removes rolls:{d}", .{count});
}

fn removeRolls(map:*Map) usize{
    var count:usize = 0;

    const yMax = map.items.len;
    var y:usize = 0;
    while(y < yMax):(y += 1){
        const xRow = map.items[y];
        const xMax = xRow.items.len;
        var x: usize = 0;
        while(x < xMax):(x += 1){
            if(!xRow.items[x]) continue;
            if(has4orMoreNeighbours(x, y, map, xMax, yMax)) continue;
            map.items[y].items[x] = false;
            count += 1;
        }
    }
    std.log.info("Rolls:{d}", .{count});
    return count;
}

fn countAccessableRolls(map:*const Map) void{
    var count:usize = 0;

    const yMax = map.items.len;
    var y:usize = 0;
    while(y < yMax):(y += 1){
        const xRow = map.items[y];
        const xMax = xRow.items.len;
        var x: usize = 0;
        while(x < xMax):(x += 1){
            if(!xRow.items[x]) continue;
            if(has4orMoreNeighbours(x, y, map, xMax, yMax)) continue;
            count += 1;
        }
    }
    std.log.info("Rolls:{d}", .{count});
}

fn has4orMoreNeighbours(x:usize, y:usize, map:*const Map, xMax: usize, yMax: usize) bool{
    var neighbourCount:usize = 0;
    const xStart = if(x == 0) 0 else x - 1;
    //zig for is like start < end not <=
    const xEnd = if(x >= xMax - 1) xMax else x + 2;
    for(xStart..xEnd)|xNeighbour|{
        const yStart = if(y == 0) 0 else y - 1;
        const yEnd = if(y >= yMax - 1) yMax else y + 2;
        for(yStart..yEnd)|yNeighbour|{
            if(yNeighbour == y and xNeighbour == x) continue;
            if(!map.items[yNeighbour].items[xNeighbour]) continue;
            neighbourCount += 1;
        }
    }
    const has4orMore = neighbourCount >= 4;
    std.log.debug("x:{d} y:{d} - {s} (count:{d})", .{x,y, if(has4orMore)"lift" else "inaccessable", neighbourCount});
    return has4orMore;
}

fn readMap(entryItr:*help.StrIterator, alloc: std.mem.Allocator)!Map{ 
    var map:Map = .empty;
    while(entryItr.next())|line|{
        var row:std.ArrayList(bool) = .empty;
        for(line)|char|{
            const isPaper = char == '@';
            try row.append(alloc, isPaper);
        }  
        try map.append(alloc, row);
    }
    return map;
}

