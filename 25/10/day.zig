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
    buttons:std.ArrayList(Button) = .empty,

    fn cleanState(machine:*const Machine)void{
        for(0..machine.lights.items.len)|i|{
            machine.lights.items[i].state = false;
        }
    }

    fn isRunning(machine:*const Machine) bool{
        for(machine.lights.items)|light|{
            if(light.state != light.goal) return false;
        }
        return true;
    }

    fn press(machine:*const Machine, button:*const Button) void{
        for(button.toggles.items)|toggle|{
            machine.lights.items[toggle].state = !machine.lights.items[toggle].state;
        }
    }
};

const errs = error{
    NotFound
};

fn partOne(lineItr:*help.StrIterator, common:*const help.CommonWrapper) !void{
    var machines:std.ArrayList(Machine) = .empty;
    while(lineItr.next())|line|{
        try machines.append(common.alloc, try createMachine(line, common.alloc));
    }

    var result:usize = 0;
    for(machines.items)|machine|{
        const fewestPresses = try findMinimumPress(&machine);
        std.log.debug("minPress:{d}", .{fewestPresses});
        result += fewestPresses;
    }
    std.log.debug("result:{d}", .{result});
}

fn findMinimumPress(machine:*const Machine) !usize{
    for(machine.buttons.items)|button|{
        //try lights
        machine.press(&button);

        if(machine.isRunning()) return 1;
        //reset press
        machine.press(&button);
    }

    //go until press depth count
    for(2..machine.lights.items.len)|count|{
        for(machine.buttons.items)|button|{
            machine.press(&button);

            if(recursiveUntil(machine, count, 1)) return count;

            machine.cleanState();
        }
    }
    
    std.log.err("unable to finde min press for {}", .{machine});
    return errs.NotFound;
}

fn recursiveUntil(machine:*const Machine, until:usize, current:usize) bool{
    if(current + 1 > until) return false;

    for(machine.buttons.items)|button|{
        machine.press(&button);

        if(machine.isRunning()) return true;
        if(recursiveUntil(machine, until, current+1)) return true;

        machine.press(&button);
    }

    return false;
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
