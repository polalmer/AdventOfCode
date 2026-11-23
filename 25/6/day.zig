const std = @import("std");
const help = @import("../helper.zig");

pub fn six(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "6", &common);
    if(common.runTaskOne){
        //hard codec opLine
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    //init result list
    var results:std.ArrayList(std.ArrayList(usize)) = .empty;
    var useAddition:std.ArrayList(bool) = .empty;
    while(lineItr.next())|line|{
        var colItr = std.mem.tokenizeSequence(u8, line, " ");
        var colIndex:usize = 0;
        while(colItr.next())|col|{
            if(col[0] == '*' or col[0] == '+'){
                try useAddition.append(common.alloc, col[0] == '+');
                continue;
            }
            if(results.items.len <= colIndex){
                try results.append(common.alloc, .empty);
            }
            try results.items[colIndex].append(common.alloc, try std.fmt.parseInt(usize, col, 10));
            colIndex += 1;
        }
    }

    var result:usize = 0;
    for(0..results.items.len)|row|{
        for(1..results.items[row].items.len)|int|{
            if(useAddition.items[row]){
                results.items[row].items[0] += results.items[row].items[int];
            }
            else{
                results.items[row].items[0] *= results.items[row].items[int];
            }
        }

        result += results.items[row].items[0];
        std.log.debug("rowsult:{d}", .{results.items[row].items[0]});
    }
    std.log.debug("result:{d}", .{result});
}


fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    //read the whole grid into mem
    var strGrid:std.ArrayList([]const u8) = .empty;
    while(lineItr.next())|line|{
        try strGrid.append(common.alloc, line);
    }

    var result:usize = 0;

    var isAddition = true;
    var numbers:std.ArrayList(usize) = .empty;
    //failes to calculate the last problem
    for(0..strGrid.items[0].len)|colIndex|{
        var numStr:std.ArrayList(u8) = .empty;
        for(strGrid.items)|line|{
            const char = line[colIndex];
            if(isNumberChar(char)){
                try numStr.append(common.alloc, char);
            }
            else if(char == '*'){
                isAddition = false; 
            }
        }

        if(std.mem.eql(u8, numStr.items, "")){
            //calculate operation
            var problem:usize = if(isAddition) 0 else 1;
            for(numbers.items)|int|{
                if(isAddition){
                    problem += int;
                }
                else{
                    problem *= int;
                }
            }
            std.log.debug("problem:{d}", .{problem});
            numbers.clearAndFree(common.alloc);
            isAddition = true;
            result += problem;
        }
        else{ 
            const int = try std.fmt.parseInt(usize, numStr.items, 10);
            std.log.debug("Parsed Int:{d}", .{int});
            try numbers.append(common.alloc, int);
        }
    }
    //calculate operation
    var problem:usize = if(isAddition) 0 else 1;
    for(numbers.items)|int|{
        if(isAddition){
            problem += int;
        }
        else{
            problem *= int;
        }
    }
    std.log.debug("problem:{d}", .{problem});
    numbers.clearAndFree(common.alloc);
    isAddition = true;
    result += problem;


    std.log.debug("result:{d}", .{result});
}


fn isNumberChar(char:u8) bool{
    if(char < '1') return false;
    if(char > '9') return false;
    return true;
}
