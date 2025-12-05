const std = @import("std");
const posting = @import("reverse_index/posting.zig");
const ranking = @import("reverse_index/ranking.zig");
const markdown = @import("markdown/parser.zig");
const recipeParser = @import("recipe_parser.zig");

pub const ReverseIndex = struct {
    allocator: std.mem.Allocator,
    dictionary: std.StringHashMap(posting.Postings),

    pub fn init(allocator: std.mem.Allocator) ReverseIndex {
        return ReverseIndex{ .allocator = allocator, .dictionary = std.StringHashMap(posting.Postings).init(allocator) };
    }

    pub fn deinit(self: *ReverseIndex) void {
        var it = self.dictionary.iterator();
        while (it.next()) |entry| {
            // the key's backing word was cloned
            // deallocate the key of the hash
            self.allocator.free(entry.key_ptr.*);
            // deallocate the posting list
            entry.value_ptr.deinit();
        }
        self.dictionary.deinit();
    }

    pub fn indexDocument(self: *ReverseIndex, document: struct { doc_id: u32, data: recipeParser.RecipeData }) !void {
        var postings_map = std.StringHashMap(posting.Posting).init(self.allocator);
        defer postings_map.deinit();

        try updateDocumentPostings(&postings_map, document.data.title, document.doc_id, .title);
        try updateDocumentPostings(&postings_map, document.data.tags, document.doc_id, .tags);
        try updateDocumentPostings(&postings_map, document.data.ingredients, document.doc_id, .ingredients);

        var postings_map_it = postings_map.iterator();
        while (postings_map_it.next()) |entry| {
            try self.updateIndex(entry.key_ptr.*, entry.value_ptr.*);
        }
    }

    fn updateDocumentPostings(postings_map: *std.StringHashMap(posting.Posting), terms_list: std.ArrayList([]const u8), doc_id: u32, field: posting.Field) !void {
        for (terms_list.items) |term| {
            const gop = try postings_map.getOrPut(term);

            if (!gop.found_existing) {
                gop.key_ptr.* = term;
                gop.value_ptr.* = posting.Posting.init(doc_id, field);
            } else {
                gop.value_ptr.addField(field);
            }
            gop.value_ptr.term_frequency += 1;
        }
    }

    fn updateIndex(self: *ReverseIndex, key: []const u8, posting_item: posting.Posting) !void {
        const gop = try self.dictionary.getOrPut(key);
        if (!gop.found_existing) {
            gop.key_ptr.* = try self.allocator.dupe(u8, key);
            gop.value_ptr.* = posting.Postings.init(self.allocator);
        }
        try gop.value_ptr.append(posting_item);
    }

    pub fn debugIndex(self: *ReverseIndex) void {
        var index_it = self.dictionary.iterator();
        while (index_it.next()) |entry| {
            const term = entry.key_ptr.*;
            const postings = entry.value_ptr.docs.items;

            std.debug.print("# {s} ({d} postings)\n", .{ term, postings.len });
            for (postings) |item| {
                std.debug.print("   ─ doc:{d}  freq:{d}  fields:", .{
                    item.doc_id,
                    item.term_frequency,
                });
                var iter = item.fields.iterator();
                while (iter.next()) |f| {
                    std.debug.print(" {s}", .{@tagName(f)});
                }
                std.debug.print("\n", .{});
            }
            std.debug.print("\n", .{});
        }
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    const source =
        \\# Scrambled Eggs
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
    const recipe_data = try recipe_parser.parse(lines);

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();
    try ri.indexDocument(.{ .doc_id = 0, .data = recipe_data });

    const source2 =
        \\# Pasta Carbonara
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

    var recipe_parser2 = recipeParser.RecipeParser.init(allocator);
    defer recipe_parser2.deinit();
    const recipe_data2 = try recipe_parser2.parse(lines2);

    try ri.indexDocument(.{ .doc_id = 1, .data = recipe_data2 });
    ri.debugIndex();
}

// Test dataset for IDF ranking:
// - 5 recipes total (N=5)
// - "salt" appears in all 5 recipes → IDF = log(5/5) = 0 (very common, low discriminative value)
// - "chicken" appears in 3 recipes → IDF = log(5/3) ≈ 0.51
// - "pasta" appears in 2 recipes → IDF = log(5/2) ≈ 0.92
// - "truffle" appears in 1 recipe → IDF = log(5/1) ≈ 1.61 (rare, high discriminative value)
test "IDF ranking dataset" {
    const allocator = std.testing.allocator;

    // Recipe 1: Chicken Salad (contains: chicken, salt, lettuce, olive oil)
    const recipe1 =
        \\# Chicken Salad
        \\
        \\## tags
        \\salad, healthy, lunch, chicken
        \\
        \\## ingredients
        \\- chicken breast
        \\- salt
        \\- lettuce
        \\- olive oil
    ;

    // Recipe 2: Chicken Pasta (contains: chicken, pasta, salt, garlic)
    const recipe2 =
        \\# Chicken Pasta
        \\
        \\## tags
        \\pasta, italian, dinner, chicken
        \\
        \\## ingredients
        \\- chicken breast
        \\- pasta
        \\- salt
        \\- garlic
    ;

    // Recipe 3: Truffle Pasta (contains: pasta, truffle, salt, butter)
    const recipe3 =
        \\# Truffle Pasta
        \\
        \\## tags
        \\pasta, italian, luxury, truffle
        \\
        \\## ingredients
        \\- pasta
        \\- truffle
        \\- salt
        \\- butter
    ;

    // Recipe 4: Grilled Chicken (contains: chicken, salt, pepper, lemon)
    const recipe4 =
        \\# Grilled Chicken
        \\
        \\## tags
        \\dinner, healthy, grilled, chicken
        \\
        \\## ingredients
        \\- chicken breast
        \\- salt
        \\- pepper
        \\- lemon
    ;

    // Recipe 5: Vegetable Soup (contains: salt, carrots, onion, celery)
    const recipe5 =
        \\# Vegetable Soup
        \\
        \\## tags
        \\soup, healthy, vegetarian, easy
        \\
        \\## ingredients
        \\- salt
        \\- carrots
        \\- onion
        \\- celery
    ;

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();

    // Parse and index all 5 recipes
    inline for (.{ recipe1, recipe2, recipe3, recipe4, recipe5 }, 0..) |source, i| {
        var parser = markdown.Parser.init(allocator, source);
        defer parser.deinit();
        const lines = try parser.parse();

        var recipe_parser = recipeParser.RecipeParser.init(allocator);
        defer recipe_parser.deinit();
        const recipe_data = try recipe_parser.parse(lines);

        try ri.indexDocument(.{ .doc_id = @intCast(i), .data = recipe_data });
    }

    // Verify document frequencies for IDF calculation
    const total_docs: u32 = 5;

    // "salt" should be in all 5 documents
    const salt_postings = ri.dictionary.get("salt").?;
    try std.testing.expectEqual(@as(usize, 5), salt_postings.docs.items.len);

    // "chicken" should be in 3 documents (recipes 1, 2, 4)
    const chicken_postings = ri.dictionary.get("chicken").?;
    try std.testing.expectEqual(@as(usize, 3), chicken_postings.docs.items.len);

    // "pasta" should be in 2 documents (recipes 2, 3)
    const pasta_postings = ri.dictionary.get("pasta").?;
    try std.testing.expectEqual(@as(usize, 2), pasta_postings.docs.items.len);

    // "truffle" should be in 1 document (recipe 3)
    const truffle_postings = ri.dictionary.get("truffle").?;
    try std.testing.expectEqual(@as(usize, 1), truffle_postings.docs.items.len);

    // Verify document frequencies using ranking module
    try std.testing.expectEqual(@as(usize, 5), ranking.df(&salt_postings));
    try std.testing.expectEqual(@as(usize, 3), ranking.df(&chicken_postings));
    try std.testing.expectEqual(@as(usize, 2), ranking.df(&pasta_postings));
    try std.testing.expectEqual(@as(usize, 1), ranking.df(&truffle_postings));

    // Verify IDF values using ranking module
    const salt_idf = ranking.idf(&salt_postings, total_docs);
    const chicken_idf = ranking.idf(&chicken_postings, total_docs);
    const pasta_idf = ranking.idf(&pasta_postings, total_docs);
    const truffle_idf = ranking.idf(&truffle_postings, total_docs);

    // IDF should increase as terms become rarer
    try std.testing.expect(salt_idf < chicken_idf);
    try std.testing.expect(chicken_idf < pasta_idf);
    try std.testing.expect(pasta_idf < truffle_idf);

    // salt IDF should be 0 (appears in all docs)
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), salt_idf, 0.001);

    // truffle IDF should be highest (log(5/1) ≈ 1.609)
    try std.testing.expectApproxEqAbs(@as(f64, 1.609), truffle_idf, 0.01);

    std.debug.print("\n=== IDF Ranking Test Results ===\n", .{});
    std.debug.print("Total documents: {d}\n", .{total_docs});
    std.debug.print("salt:    df={d}, IDF={d:.3}\n", .{ ranking.df(&salt_postings), salt_idf });
    std.debug.print("chicken: df={d}, IDF={d:.3}\n", .{ ranking.df(&chicken_postings), chicken_idf });
    std.debug.print("pasta:   df={d}, IDF={d:.3}\n", .{ ranking.df(&pasta_postings), pasta_idf });
    std.debug.print("truffle: df={d}, IDF={d:.3}\n", .{ ranking.df(&truffle_postings), truffle_idf });
}
