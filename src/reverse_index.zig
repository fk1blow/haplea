const std = @import("std");
const posting = @import("reverse_index/posting.zig");
const markdown = @import("markdown/parser.zig");
const recipeParser = @import("recipe_parser.zig");

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

    pub fn indexDocument(self: *ReverseIndex, document: struct { doc_id: u32, data: recipeParser.RecipeData }) !void {
        var postings_map = std.StringHashMap(posting.Posting).init(self.allocator);
        defer postings_map.deinit();

        try updateDocumentPostings(&postings_map, document.data.title, document.doc_id, .title);
        try updateDocumentPostings(&postings_map, document.data.tags, document.doc_id, .tags);
        try updateDocumentPostings(&postings_map, document.data.ingredients, document.doc_id, .ingredients);

        var postings_map_it = postings_map.iterator();
        while (postings_map_it.next()) |entry| {
            try self.addPosting(entry.key_ptr.*, entry.value_ptr.*);
        }
    }

    fn updateDocumentPostings(postings_map: *std.StringHashMap(posting.Posting), terms_list: std.ArrayList([]const u8), doc_id: u32, field: posting.Field) !void {
        for (terms_list.items) |term| {
            const gop = try postings_map.getOrPut(term);

            if (!gop.found_existing) {
                gop.key_ptr.* = term;
                gop.value_ptr.* = posting.Posting.init(doc_id, field);
            }
            // TODO should update the `field` as well
            gop.value_ptr.term_frequency = gop.value_ptr.term_frequency + 1;
            if (gop.value_ptr.field != field) {
                gop.value_ptr.term_frequency = gop.value_ptr.term_frequency + 1;
            }
        }
    }

    fn addPosting(self: *ReverseIndex, term: []const u8, item: posting.Posting) !void {
        const gop = try self.index.getOrPut(term);
        if (!gop.found_existing) {
            gop.key_ptr.* = try self.allocator.dupe(u8, term);
            gop.value_ptr.* = posting.PostingList.init(self.allocator);
        }
        try gop.value_ptr.append(item);
    }

    pub fn debugIndex(self: *ReverseIndex) void {
        var index_it = self.index.iterator();
        while (index_it.next()) |entry| {
            const term = entry.key_ptr.*;
            const postings = entry.value_ptr.items.items;

            std.debug.print("'{s}' ({d} postings)\n", .{ term, postings.len });
            for (postings) |item| {
                std.debug.print("   ─ doc:{d}  freq:{d}  field:{s}\n", .{
                    item.doc_id,
                    item.term_frequency,
                    @tagName(item.field),
                });
            }
            std.debug.print("\n", .{});
        }
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    const source =
        \\# scrambled eggs
        \\
        \\## tags
        \\breakfast, easy, eggs, butter
        \\
        \\## ingredients
        \\- eggs
        \\- butter
        \\- oil
        \\- bacon
    ;

    var parser = markdown.Parser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var recipe_parser = recipeParser.RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const recipeData = try recipe_parser.parse(lines);

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();
    try ri.indexDocument(.{ .doc_id = 0, .data = recipeData });
    // ri.debugIndex();

    const source2 =
        \\# pasta carbonara
        \\
        \\## tags
        \\pasta, italian, spachetti, carbonara, butter
        \\
        \\## ingredients
        \\- pasta
        \\- butter
        \\- oil
        \\- guanciale or bacon
        \\- parmezan
        \\- eggs
    ;

    var parser2 = markdown.Parser.init(allocator, source2);
    defer parser2.deinit();
    const lines2 = try parser2.parse();

    // var recipe_parser2 = recipeParser.RecipeParser.init(allocator);
    // defer recipe_parser2.deinit();
    const recipe_data2 = try recipe_parser.parse(lines2);

    // var ri = ReverseIndex.init(allocator);
    // defer ri.deinit();
    try ri.indexDocument(.{ .doc_id = 1, .data = recipe_data2 });
    ri.debugIndex();

    // try ri.addPosting("pasta", .{ .document_id = 39, .term_frequency = 2, .source_field = posting.SourceField.title });
    // try ri.addPosting("pasta", .{ .document_id = 2, .term_frequency = 2, .source_field = posting.SourceField.ingredients });

    // if (ri.index.get("pasta")) |postings| {
    //     for (postings.items.items) |item| {
    //         std.debug.print("found: {any}, weight: {d} \n", .{ item, item.source_field.getWeight() });
    //     }
    // }
}
