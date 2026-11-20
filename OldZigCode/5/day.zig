const std = @import("std");
const help = @import("../helper.zig");

const FreshnessList = std.ArrayList(@Vector(2,usize));

pub fn five(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "5", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    //read
    var ingredients: std.ArrayList(usize) = .empty;
    var freshRanges: std.ArrayList(@Vector(2, usize)) = .empty;

    try readIngredients(lineItr, common.alloc, &ingredients, &freshRanges);

    var freshnessCount:usize = 0;
    for(ingredients.items)|ingredient|{
        if(isFresh(ingredient, &freshRanges)){
            freshnessCount += 1;
        }
    }
    std.log.info("Count:{d}", .{freshnessCount});
}

fn isFresh(ingredient:usize, freshranges:*FreshnessList) bool{
    for(freshranges.items)|range|{
        if(ingredient >= range[0] and ingredient <= range[1]){
            std.log.debug("{d} is fresh", .{ingredient});
            return true;
        }
    }

    std.log.debug("{d} is spoiled", .{ingredient});
    return false;
}

fn readIngredients(lineItr:*help.StrIterator, alloc:std.mem.Allocator, ingredients:*std.ArrayList(usize), freshRanges:*FreshnessList) !void{
    while(lineItr.next())|line|{
        var itrRange = std.mem.tokenizeSequence(u8, line, "-");
        if(itrRange.next())|first|{
            if(itrRange.next())|second|{
                //first and second are a range
                const rangeVec = @Vector(2, usize){
                    try strToUsize(first),
                    try strToUsize(second)
                };
                try freshRanges.append(alloc, rangeVec);
            }
            else{
                // first is ingredient
                try ingredients.append(alloc, try strToUsize(first));
            }
        }
        else{
            std.log.err("Failed to parse line:{s}", .{line});
        }
    }
}


fn strToUsize(str:[]const u8) !usize{
    return try std.fmt.parseInt(usize, str, 10);
}


//I feel lost, test works, input doesnt
fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    var ingredients: std.ArrayList(usize) = .empty;
    var freshRanges: std.ArrayList(@Vector(2, usize)) = .empty;

    try readIngredients(lineItr, common.alloc, &ingredients, &freshRanges);
    
    var i:usize = 0;
    while(i < freshRanges.items.len):(i+=1){
        var compare = freshRanges.items[i];
        std.log.debug("compare:{any}",.{compare});
        //compare against all other
        var otherIndex:usize = 0;
        while(otherIndex < freshRanges.items.len){
            if(otherIndex == i){
                otherIndex += 1;
                continue;
            }
            const other = freshRanges.items[otherIndex];
            if(!overLaps(compare, other)){
                std.log.debug("c:{any} and {any} DONT overlap",.{compare, other});
                otherIndex += 1;
                continue;
            }
            std.log.debug("c:{any} and {any} overlap",.{compare, other});
            compare = combineRanges(compare, other);
            std.log.debug("c now {any}",.{compare});
            try freshRanges.replaceRange(common.alloc, i, 1, &.{compare});
            _ = freshRanges.swapRemove(otherIndex);
            otherIndex += 1;
        }
    }

    std.log.info("final ranges", .{});
    var count:usize = 0;
    for(freshRanges.items)|fresh|{
        std.log.info("{any}", .{fresh});
        count += fresh[1]-fresh[0]+1;
    }
    std.log.info("Result:{d}", .{count});
}

fn combineRanges(this:[2]usize, other:[2]usize)[2]usize{
    const newRange = .{@min(this[0], other[0]), @max(this[1], other[1])};
    return newRange;
}

pub fn overLaps(this:[2]usize, other:[2]usize)bool{
    if(this[1] < other[0]) return false;
    if(this[0] > other[1]) return false;
    return true;
}

const expect = std.testing.expect;
test "overLap"{
    try expect(overLaps(.{1,10},.{2,5}));
    try expect(overLaps(.{2,5},.{1,10}));
    try expect(overLaps(.{2,5},.{1,3}));
    try expect(overLaps(.{1,3},.{2,5}));
    try expect(overLaps(.{2,5},.{4,6}));
    try expect(overLaps(.{4,6},.{2,5}));
}
test "dontOverlap"{
    try expect(!overLaps(.{1,2},.{3,5}));
    try expect(!overLaps(.{3,5},.{1,2}));
}
