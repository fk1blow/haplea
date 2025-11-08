const std = @import("std");
const parser = @import("parser.zig");

pub fn main() !void {
    std.debug.print("Haplea - Recipe Parser\n", .{});
    std.debug.print("=====================\n\n", .{});

    // For now, parse a simple example directly
    const example =
        \\# Scrambled Eggs
        \\
        \\Easy, fast and good recipe.
        \\
        \\## tags
        \\
        \\breakfast, eggs, fast food
        \\
        \\## ingredients
        \\
        \\- eggs
        \\- cheese
        \\- salt
    ;

    std.debug.print("Parsing recipe:\n", .{});
    parser.parse(example);

    std.debug.print("\nDone!\n", .{});
}
