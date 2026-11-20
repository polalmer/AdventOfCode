const std = @import("std");
const help = @import("../helper.zig");

pub fn nine(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "9", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

const Corner = struct{
    x:i64,
    y:i64
};


fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    const corners = try readCorners(lineItr, common.alloc);

    var largestArea = calcArea(&corners[0], &corners[corners.len-1]);
    
    for(0..corners.len-1)|start|{
        for(start+1..corners.len)|end|{
            const new = calcArea(&corners[start], &corners[end]);
            if(new > largestArea){
                largestArea = new;
            }
        }
    }

    std.log.info("result:{d}", .{largestArea});
}

fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    const corners = try readCorners(lineItr, common.alloc);
    var largestArea:usize = 0;
    for(0..corners.len-1)|start|{
        for(start+1..corners.len)|end|{
            if(canNavigateTo(start, end, corners)){
                std.log.debug("Rect is inside:\nc1{}\nc2{}", .{corners[start], corners[end]});
                //check
                const new = calcArea(&corners[start], &corners[end]);
                if(new > largestArea){
                    largestArea = new;
                }
            }
        }
    }
    std.log.info("largest area:{d}", .{largestArea});
}

//work for example too low for real
fn canNavigateTo(startI:usize, endI:usize, polygon:[]Corner)bool{
    const minX = @min(polygon[startI].x, polygon[endI].x);
    const maxX = @max(polygon[startI].x, polygon[endI].x);
    for(startI+1..endI)|index|{
        const next = polygon[index];
        const prev = polygon[index-1];
        if(next.x == prev.x) continue;
        //moved left
        if(next.x < prev.x){
            if(next.x < maxX) return false;
        }
        //moved right
        else{
            if(next.x > minX) return false;
        }
    }
    return true;
}

fn readCorners(lineItr:*help.StrIterator, alloc:std.mem.Allocator)![]Corner{
    var corners:std.ArrayList(Corner) = .empty;
    while(lineItr.next())|line|{
        var commaIndex:u8 = 0;
        while(line[commaIndex] != ','):(commaIndex += 1){}
        const x = try std.fmt.parseInt(i64, line[0..commaIndex], 10);
        const y = try std.fmt.parseInt(i64, line[commaIndex+1..], 10);

        try corners.append(alloc, Corner{.x=x, .y=y});
    }
    return corners.items;
}

fn calcArea(top:*const Corner, bot:*const Corner) usize{
    return @abs(top.x - bot.x + 1) * @abs(top.y - bot.y + 1);
}

