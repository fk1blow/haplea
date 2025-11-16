const std = @import("std");
const markdown = @import("markdown.zig");
const recipe = @import("recipe_extractor.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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

    // Phase 1: Parse markdown into lines
    var parser = markdown.MarkdownParser.init(allocator, example);
    defer parser.deinit();

    const lines = try parser.parse();
    std.debug.print("Parsed {d} lines\n", .{lines.len});

    // Phase 2: Extract recipe data
    var extractor = recipe.RecipeExtractor.init(allocator);
    defer extractor.deinit();

    const recipe_data = extractor.extract(lines) catch |err| {
        std.debug.print("\nError extracting recipe: {}\n", .{err});
        return err;
    };

    // Print the extracted recipe
    std.debug.print("\n=== Recipe Data ===\n", .{});
    std.debug.print("Title: {s}\n\n", .{recipe_data.title});

    std.debug.print("Tags ({d}):\n", .{recipe_data.tags.items.len});
    for (recipe_data.tags.items, 0..) |tag, i| {
        std.debug.print("  [{d}] {s}\n", .{ i, tag });
    }

    std.debug.print("\nIngredients ({d}):\n", .{recipe_data.ingredients.items.len});
    for (recipe_data.ingredients.items, 0..) |ingredient, i| {
        std.debug.print("  [{d}] {s}\n", .{ i, ingredient });
    }

    std.debug.print("\nDone!\n", .{});
}
