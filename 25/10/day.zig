const std = @import("std");
const help = @import("../helper.zig");

pub fn ten(common:help.CommonWrapper) !void{
    var itr = try help.getFileIterator("\n", "10", &common);
    if(common.runTaskOne){
        try partOne(&itr, &common);
    }
    else{
        try partTwo(&itr, &common);
    }
}

const Light = struct{
    state: bool = false,
    goal: bool
};

const Button = struct{
    toggles:std.ArrayList(usize) = .empty
};

const Machine = struct{
    lights:std.ArrayList(Light) = .empty,
    buttons:std.ArrayList(Button) = .empty
};

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var machines:std.ArrayList(Machine) = .empty;
    while(lineItr.next())|line|{
        try machines.append(common.alloc, try createMachine(line, common.alloc));
    }
}

fn createMachine(line:[]const u8, alloc:std.mem.Allocator) !Machine{
    var machine = Machine{};
    for(0..line.len)|i|{
        switch(line[i]){
            '.' => try machine.lights.append(alloc, Light{.goal = false}),
            '#' => try machine.lights.append(alloc, Light{.goal = true}),
            '(' => try machine.buttons.append(alloc, try createButton(line, i+1, alloc)),
            else => continue
        }
    }
    return machine;
}

fn createButton(line:[]const u8, start:usize, alloc:std.mem.Allocator)!Button{
    var button = Button{};
    var i = start;
    var numStart = i;
    while(line[i] != ')'):(i += 1){
        if(line[i] != ',') continue;
        //read num and set new numstart
        const num = try std.fmt.parseInt(usize, line[numStart..i], 10);
        try button.toggles.append(alloc, num);
        numStart = i + 1;
    }
    const num = try std.fmt.parseInt(usize, line[numStart..i], 10);
    try button.toggles.append(alloc, num);
    return button;
}

fn partTwo(lineItr:*help.StrIterator, common: *const help.CommonWrapper) !void{
    _ = .{lineItr, common};
}
