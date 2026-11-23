const std = @import("std");
const help = @import("../helper.zig");

const JunctionBox = struct{
    x:f64 = 0,
    y:f64 = 0,
    z:f64 = 0,
    circuit:?usize = null,

    fn equals(box:*const JunctionBox, other:*const JunctionBox) bool{
        return box.x == other.x and box.y == other.y and box.z == other.z;
    }

    fn distance(box:*const JunctionBox, other:*const JunctionBox) f64{
        const x = box.x - other.x; 
        const y = box.y - other.y;
        const z = box.z - other.z;
        return @sqrt(x*x + y*y + z*z);
    }
};

pub fn eight(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "8", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var boxes:std.ArrayList(JunctionBox) = .empty;
    //read position
    while(lineItr.next())|line|{
        var posItr = std.mem.tokenizeSequence(u8, line, ",");
        var box:JunctionBox = .{};
        for(0..3)|index|{
            if(posItr.next())|posStr|{
                const pos = try std.fmt.parseFloat(f64, posStr); 
                switch(index){
                    0 => box.x = pos,
                    1 => box.y = pos,
                    else => box.z = pos
                }
            }
        }
        try boxes.append(common.alloc, box);
    }

    const connect:usize = if(common.useExample) 10 else 1000;
    const pairs = try getSortedPairs(boxes.items, common.alloc, connect); 

    var circuits:std.ArrayList(std.ArrayList(*JunctionBox)) = .empty;
    for(0..connect)|index|{
        const pair = pairs[index];
        std.log.debug("pair\nbox{}\nother{}", .{pair.box, pair.other});

        //new ciruit
        if(pair.box.circuit == null and pair.other.circuit == null){
            try circuits.append(common.alloc, .empty);
            const circuit = circuits.items.len - 1;
            const last = &circuits.items[circuit];
            pair.box.circuit = circuit;
            try last.append(common.alloc, pair.box);
            pair.other.circuit = circuit;
            try last.append(common.alloc, pair.other);
        }
        else if(pair.box.circuit == null){
            pair.box.circuit = pair.other.circuit; 
            try circuits.items[pair.box.circuit.?].append(common.alloc, pair.box);
        }
        else if(pair.other.circuit == null){
            pair.other.circuit = pair.box.circuit; 
            try circuits.items[pair.other.circuit.?].append(common.alloc, pair.other);
        }
        else{
            if(pair.box.circuit == pair.other.circuit) continue;
            const oldIndex = pair.other.circuit.?; 
            for(circuits.items[oldIndex].items)|move|{
                move.circuit = pair.box.circuit;
                try circuits.items[pair.box.circuit.?].append(common.alloc, move);
            }
            _ = circuits.orderedRemove(oldIndex);
            //update indecies of next circuits
            for(oldIndex..circuits.items.len)|updateIndex|{
                for(0..circuits.items[updateIndex].items.len)|updateItem|{
                    var item = circuits.items[updateIndex].items[updateItem];
                    item.circuit.? -= 1;
                }
            }
        }
    }

    //get counts 
    var largest:[3]usize = .{0,0,0};
    for(circuits.items)|circuit|{
        const size = circuit.items.len;
        std.log.debug("Circuit items:{d}", .{circuit.items.len});
        for(0..3)|i|{
            if(largest[i] > size) continue;
            var r:usize = 2;
            while(r > i):(r -= 1){
                largest[r] = largest[r-1];
            }
            largest[i] = size;
            break;
        }
    }

    var mult:usize = 1;
    for(largest)|size|{
        std.log.info("{d}", .{size});
        mult *= size;
    }
    std.log.info("result:{d}", .{mult});
}

fn getSortedPairs(boxes:[]JunctionBox, alloc:std.mem.Allocator, max:usize) ![]Pair{
    var pairs:std.ArrayList(Pair) = .empty;
    for(0 .. boxes.len - 1)|boxIndex|{
        const box = &boxes[boxIndex];
        for(boxIndex+1 .. boxes.len)|otherIndex|{
            //build pair
            const other = &boxes[otherIndex];
            const pair = Pair{
                .box = box,
                .other = other,
                .distance = box.distance(other)
            };
            var sortI:usize = 0;
            while(sortI < pairs.items.len 
                and pairs.items[sortI].distance < pair.distance
                and sortI <= max)
                :(sortI += 1){}

            //reduces unnecessary checks
            if(sortI > max) continue;
            try pairs.insert(alloc, sortI, pair);
        }
    }
    return pairs.items;
}

const Pair = struct{
    box: *JunctionBox,
    other: *JunctionBox,
    distance: f64
};

fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    var boxes:std.ArrayList(JunctionBox) = .empty;
    //read position
    while(lineItr.next())|line|{
        var posItr = std.mem.tokenizeSequence(u8, line, ",");
        var box:JunctionBox = .{};
        for(0..3)|index|{
            if(posItr.next())|posStr|{
                const pos = try std.fmt.parseFloat(f64, posStr); 
                switch(index){
                    0 => box.x = pos,
                    1 => box.y = pos,
                    else => box.z = pos
                }
            }
        }
        try boxes.append(common.alloc, box);
    }

    //could be faster if dynamic idc
    const max = boxes.items.len * 10;
    const pairs = try getSortedPairs(boxes.items, common.alloc, max); 

    const lastPair = try connectBoxes(boxes.items, pairs, common.alloc);
    std.log.debug("lastpair:{}", .{lastPair});
    const result = lastPair.box.x * lastPair.other.x;
    std.log.info("result:{d}", .{result});
}

const errors = error{
    NoLastPairFound
};

fn connectBoxes(boxes:[]JunctionBox, pairs:[]Pair, alloc:std.mem.Allocator) !Pair{
    var circuits:std.ArrayList(std.ArrayList(*JunctionBox)) = .empty;
    var index:usize = 0;
    var pair:Pair = pairs[index];
    while(notOneCircuit(boxes, circuits.items.len)) : (index += 1){
        pair = pairs[index];
        
        std.log.debug("pair\nbox{}\nother{}", .{pair.box, pair.other});

        //new ciruit
        if(pair.box.circuit == null and pair.other.circuit == null){
            try circuits.append(alloc, .empty);
            const circuit = circuits.items.len - 1;
            const last = &circuits.items[circuit];
            pair.box.circuit = circuit;
            try last.append(alloc, pair.box);
            pair.other.circuit = circuit;
            try last.append(alloc, pair.other);
        }
        else if(pair.box.circuit == null){
            pair.box.circuit = pair.other.circuit; 
            try circuits.items[pair.box.circuit.?].append(alloc, pair.box);
        }
        else if(pair.other.circuit == null){
            pair.other.circuit = pair.box.circuit; 
            try circuits.items[pair.other.circuit.?].append(alloc, pair.other);
        }
        else{
            if(pair.box.circuit == pair.other.circuit) continue;
            const oldIndex = pair.other.circuit.?; 
            for(circuits.items[oldIndex].items)|move|{
                move.circuit = pair.box.circuit;
                try circuits.items[pair.box.circuit.?].append(alloc, move);
            }
            _ = circuits.orderedRemove(oldIndex);
            //update indecies of next circuits
            for(oldIndex..circuits.items.len)|updateIndex|{
                for(0..circuits.items[updateIndex].items.len)|updateItem|{
                    var item = circuits.items[updateIndex].items[updateItem];
                    item.circuit.? -= 1;
                }
            }

        }
    }

    return pair;
}

fn notOneCircuit(boxes:[]JunctionBox, circuitCount:usize) bool{
    for(boxes)|box|{
        if(box.circuit == null) return true;
    }
    return circuitCount != 1;
}
