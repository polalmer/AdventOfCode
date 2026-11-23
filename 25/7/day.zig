const std = @import("std");
const help = @import("../helper.zig");

pub fn seven(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "7", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var beams:std.ArrayList(bool) = .empty;
    defer beams.clearAndFree(common.alloc);
    try beams.appendNTimes(common.alloc, false, lineItr.peek().?.len);
    var splitCount:usize = 0;
    while(lineItr.next())|line|{
        for(0..line.len)|index|{
            switch(line[index]){
                'S' => {
                    beams.items[index] = true;
                    break;
                },
                '^' => {
                    if(!beams.items[index])
                        continue;
                    beams.items[index] = false;
                    beams.items[index+1] = true;
                    beams.items[index-1] = true;
                    splitCount += 1;
                },
                else => {}
            }
        }   
    }
    std.log.debug("count:{d}", .{splitCount});
}

fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    var timelinesOnIndex:std.ArrayList(usize) = .empty;
    defer timelinesOnIndex.clearAndFree(common.alloc);
    try timelinesOnIndex.appendNTimes(common.alloc, 0, lineItr.peek().?.len);

    while(lineItr.next())|line|{
        for(0..line.len)|index|{
            switch(line[index]){
                'S' => {
                    timelinesOnIndex.items[index] = 1;
                    break;
                },
                '^' => {
                    if(timelinesOnIndex.items[index] == 0)
                        continue;
                    const currentTimelines = timelinesOnIndex.items[index];
                    //join timelines on a single index
                    timelinesOnIndex.items[index+1] += currentTimelines;
                    timelinesOnIndex.items[index-1] += currentTimelines;
                    timelinesOnIndex.items[index] = 0;
                },
                else => {}
            }
        }   
    }
    var count:usize = 0;
    for(timelinesOnIndex.items)|timeline|{
        count += timeline;
    }
    std.log.debug("timlineCount:{d}", .{count});
}

