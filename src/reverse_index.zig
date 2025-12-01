const std = @import("std");
const posting = @import("reverse_index/posting.zig");
const markdown = @import("markdown/parser.zig");
const recipeExtractor = @import("recipe_extractor.zig");

pub const ReverseIndex = struct {
    allocator: std.mem.Allocator,
    index: std.StringHashMap(posting.PostingList),

    pub fn init(allocator: std.mem.Allocator) ReverseIndex {
        return ReverseIndex{ .allocator = allocator, .index = std.StringHashMap(posting.PostingList).init(allocator) };
    }

    pub fn deinit(self: *ReverseIndex) void {
        var it = self.index.iterator();
        while (it.next()) |entry| {
            // deallocate the key of the hash
            self.allocator.free(entry.key_ptr.*);
            // deallocate the posting list
            entry.value_ptr.deinit();
        }
        self.index.deinit();
    }

    fn addPosting(self: *ReverseIndex, term: []const u8, item: posting.Posting) !void {
        const gop = try self.index.getOrPut(term);
        if (!gop.found_existing) {
            // clone the term
            gop.key_ptr.* = try self.allocator.dupe(u8, term);
            gop.value_ptr.* = posting.PostingList.init(self.allocator);
        }
        try gop.value_ptr.append(item);
    }

    pub fn indexDocument(self: *ReverseIndex, document: struct { data: recipeExtractor.RecipeData }) !void {
        var terms_map = std.StringHashMap(posting.Posting).init(self.allocator);
        defer terms_map.deinit();

        try updatePosting(&terms_map, document.data.title, .title);
        try updatePosting(&terms_map, document.data.tags, .tags);
        try updatePosting(&terms_map, document.data.ingredients, .ingredients);

        var it = terms_map.iterator();
        while (it.next()) |entry| {
            std.debug.print("key: {s}, value: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }

    fn updatePosting(terms_map: *std.StringHashMap(posting.Posting), terms_list: std.ArrayList([]const u8), source_field: posting.SourceField) !void {
        for (terms_list.items) |term| {
            const gop = try terms_map.getOrPut(term);

            if (!gop.found_existing) {
                gop.key_ptr.* = term;
                gop.value_ptr.* = posting.Posting{ .document_id = 0, .term_frequency = 0, .source_field = source_field };
            }
            gop.value_ptr.term_frequency = gop.value_ptr.term_frequency + 1;
        }
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    const source =
        \\# Scrambled Eggs
        \\
        \\## tags
        \\breakfast, easy, eggs
        \\
        \\## ingredients
        \\- eggs
        \\- butter
    ;

    var parser = markdown.Parser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = recipeExtractor.RecipeExtractor.init(allocator);
    defer extractor.deinit();
    const recipeLines = try extractor.extract(lines);

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();
    try ri.indexDocument(.{ .data = recipeLines });

    // try ri.addPosting("pasta", .{ .document_id = 39, .term_frequency = 2, .source_field = posting.SourceField.title });
    // try ri.addPosting("pasta", .{ .document_id = 2, .term_frequency = 2, .source_field = posting.SourceField.ingredients });

    // if (ri.index.get("pasta")) |postings| {
    //     for (postings.items.items) |item| {
    //         std.debug.print("found: {any}, weight: {d} \n", .{ item, item.source_field.getWeight() });
    //     }
    // }
}
