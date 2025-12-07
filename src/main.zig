const std = @import("std");
const appPaths = @import("app_paths.zig");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    print("App starting...\n", .{});

    const home_path = try appPaths.getDocumentsPath(allocator);
    print("home path is {s} \n", .{home_path});
}
