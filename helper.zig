const std = @import("std");

pub const StrIterator = std.mem.TokenIterator(u8, std.mem.DelimiterType.sequence);

pub fn getFileIterator(descriminator:[]const u8, dayFolderName:[]const u8, common:*const CommonWrapper) !StrIterator{
    const dir = std.Io.Dir.cwd();
    const subPath = try std.fmt.allocPrint(common.alloc, "{s}", .{dayFolderName});
    const file = if (common.useExample) "example.txt" else "input.txt"; 
    const subDir = try std.Io.Dir.openDir(dir, common.io, subPath, std.Io.Dir.OpenOptions{});
 
    const contents = try std.Io.Dir.readFileAlloc(subDir, common.io, file, common.alloc, .unlimited);
    return std.mem.tokenizeSequence(u8, contents, descriminator);
}

pub const CommonWrapper = struct{
    useExample:bool,
    runTaskOne:bool,
    io: std.Io,
    alloc: std.mem.Allocator,
};

pub fn _u64(int:anytype) usize{
    switch(@TypeOf(int)){
        i64 => return @as(usize, @max(int, 0)),
        else => unreachable
    }
}

pub fn _i64(int:anytype) i64{
    switch(@TypeOf(int)){
        usize => return @as(i64, @min(int, 0x0FFFFFFFFF)),
        else => unreachable
    }
}
