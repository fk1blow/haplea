const std = @import("std");
const posting = @import("reverse_index/posting.zig");
const ranking = @import("reverse_index/ranking.zig");
const markdown = @import("markdown/parser.zig");
const recipeParser = @import("recipe_parser.zig");
const stop_words = @import("text/stop_words.zig");

const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const ArrayList = std.ArrayList;
const testing = std.testing;
const debug = std.debug;

pub const ReverseIndex = struct {
    allocator: Allocator,
    dictionary: StringHashMap(posting.Postings),
    doc_count: u32 = 0,

    pub fn init(allocator: Allocator) ReverseIndex {
        return ReverseIndex{
            .allocator = allocator,
            .dictionary = StringHashMap(posting.Postings).init(allocator),
        };
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

    pub fn indexDocument(
        self: *ReverseIndex,
        document: struct { document_id: u32, data: recipeParser.RecipeData },
    ) !void {
        var postings_map = StringHashMap(posting.Posting).init(self.allocator);
        defer postings_map.deinit();

        try updateDocumentPostings(&postings_map, document.data.title, document.document_id, .title);
        try updateDocumentPostings(&postings_map, document.data.tags, document.document_id, .tags);
        try updateDocumentPostings(&postings_map, document.data.ingredients, document.document_id, .ingredients);

        var postings_map_it = postings_map.iterator();
        while (postings_map_it.next()) |entry| {
            try self.updateIndex(entry.key_ptr.*, entry.value_ptr.*);
        }

        // Index full normalized title as phrase (no stop word filtering for phrases)
        if (document.data.title_phrase.len > 0) {
            try self.updateIndex(
                document.data.title_phrase,
                posting.Posting.init(document.document_id, .title_phrase),
            );
        }

        self.doc_count += 1;
    }

    fn updateDocumentPostings(
        postings_map: *StringHashMap(posting.Posting),
        terms_list: ArrayList([]const u8),
        document_id: u32,
        field: posting.Field,
    ) !void {
        for (terms_list.items) |term| {
            // Skip stop words for word-based indexing
            if (stop_words.isStopWord(term)) {
                continue;
            }

            const gop = try postings_map.getOrPut(term);

            if (!gop.found_existing) {
                gop.key_ptr.* = term;
                gop.value_ptr.* = posting.Posting.init(document_id, field);
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

            debug.print("# {s} ({d} postings)\n", .{ term, postings.len });
            for (postings) |item| {
                debug.print("   ─ doc:{d}  freq:{d}  fields:", .{
                    item.document_id,
                    item.term_frequency,
                });
                var iter = item.fields.iterator();
                while (iter.next()) |f| {
                    debug.print(" {s}", .{@tagName(f)});
                }
                debug.print("\n", .{});
            }
            debug.print("\n", .{});
        }
    }
};

test "populate the index and debug it" {
    const allocator = testing.allocator;

    // Recipe with stop words: "the", "with", "a", "of", "and"
    const source =
        \\# The Scrambled Eggs
        \\
        \\## tags
        \\breakfast, easy and quick, eggs, butter
        \\
        \\## ingredients
        \\- a few eggs
        \\- butter with salt
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
    try ri.indexDocument(.{ .document_id = 0, .data = recipe_data });

    // Recipe with stop words: "or", "with", "some"
    const source2 =
        \\# Pasta Carbonara
        \\
        \\## tags
        \\pasta, italian, spachetti, carbonara, butter
        \\
        \\## ingredients
        \\- some pasta
        \\- butter
        \\- oil
        \\- guanciale or bacon
        \\- parmezan with pepper
        \\- eggs
    ;

    var parser2 = markdown.Parser.init(allocator, source2);
    defer parser2.deinit();
    const lines2 = try parser2.parse();

    var recipe_parser2 = recipeParser.RecipeParser.init(allocator);
    defer recipe_parser2.deinit();
    const recipe_data2 = try recipe_parser2.parse(lines2);

    try ri.indexDocument(.{ .document_id = 1, .data = recipe_data2 });

    // Verify stop words are NOT indexed
    try testing.expect(ri.dictionary.get("the") == null);
    try testing.expect(ri.dictionary.get("a") == null);
    try testing.expect(ri.dictionary.get("and") == null);
    try testing.expect(ri.dictionary.get("with") == null);
    try testing.expect(ri.dictionary.get("or") == null);
    try testing.expect(ri.dictionary.get("some") == null);
    try testing.expect(ri.dictionary.get("few") == null);

    // Verify content words ARE indexed
    try testing.expect(ri.dictionary.get("scrambled") != null);
    try testing.expect(ri.dictionary.get("eggs") != null);
    try testing.expect(ri.dictionary.get("breakfast") != null);
    try testing.expect(ri.dictionary.get("easy") != null);
    try testing.expect(ri.dictionary.get("quick") != null);
    try testing.expect(ri.dictionary.get("butter") != null);
    try testing.expect(ri.dictionary.get("salt") != null);
    try testing.expect(ri.dictionary.get("pasta") != null);
    try testing.expect(ri.dictionary.get("guanciale") != null);
    try testing.expect(ri.dictionary.get("pepper") != null);

    // Verify title phrases are indexed (with stop words preserved)
    try testing.expect(ri.dictionary.get("the scrambled eggs") != null);
    try testing.expect(ri.dictionary.get("pasta carbonara") != null);

    ri.debugIndex();
}

test "IDF ranking dataset" {
    // Test dataset for IDF ranking:
    // - 5 recipes total (N=5)
    // - "salt" appears in all 5 recipes → IDF = log(5/5) = 0 (very common, low discriminative value)
    // - "chicken" appears in 3 recipes → IDF = log(5/3) ≈ 0.51
    // - "pasta" appears in 2 recipes → IDF = log(5/2) ≈ 0.92
    // - "truffle" appears in 1 recipe → IDF = log(5/1) ≈ 1.61 (rare, high discriminative value)

    const allocator = testing.allocator;

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

        try ri.indexDocument(.{ .document_id = @intCast(i), .data = recipe_data });
    }

    // Verify doc_count is tracked correctly
    try testing.expectEqual(@as(u32, 5), ri.doc_count);

    // "salt" should be in all 5 documents
    const salt_postings = ri.dictionary.get("salt").?;
    try testing.expectEqual(@as(usize, 5), salt_postings.docs.items.len);

    // "chicken" should be in 3 documents (recipes 1, 2, 4)
    const chicken_postings = ri.dictionary.get("chicken").?;
    try testing.expectEqual(@as(usize, 3), chicken_postings.docs.items.len);

    // "pasta" should be in 2 documents (recipes 2, 3)
    const pasta_postings = ri.dictionary.get("pasta").?;
    try testing.expectEqual(@as(usize, 2), pasta_postings.docs.items.len);

    // "truffle" should be in 1 document (recipe 3)
    const truffle_postings = ri.dictionary.get("truffle").?;
    try testing.expectEqual(@as(usize, 1), truffle_postings.docs.items.len);

    // Verify document frequencies using ranking module
    try testing.expectEqual(@as(usize, 5), ranking.df(&salt_postings));
    try testing.expectEqual(@as(usize, 3), ranking.df(&chicken_postings));
    try testing.expectEqual(@as(usize, 2), ranking.df(&pasta_postings));
    try testing.expectEqual(@as(usize, 1), ranking.df(&truffle_postings));

    // Verify IDF values using ranking module
    const salt_idf = ranking.idf(&salt_postings, ri.doc_count);
    const chicken_idf = ranking.idf(&chicken_postings, ri.doc_count);
    const pasta_idf = ranking.idf(&pasta_postings, ri.doc_count);
    const truffle_idf = ranking.idf(&truffle_postings, ri.doc_count);

    // IDF should increase as terms become rarer
    try testing.expect(salt_idf < chicken_idf);
    try testing.expect(chicken_idf < pasta_idf);
    try testing.expect(pasta_idf < truffle_idf);

    // salt IDF should be 0 (appears in all docs)
    try testing.expectApproxEqAbs(@as(f64, 0.0), salt_idf, 0.001);

    // truffle IDF should be highest (log(5/1) ≈ 1.609)
    try testing.expectApproxEqAbs(@as(f64, 1.609), truffle_idf, 0.01);

    debug.print("\n=== IDF Ranking Test Results ===\n", .{});
    debug.print("Total documents: {d}\n", .{ri.doc_count});
    debug.print("salt:    df={d}, IDF={d:.3}\n", .{ ranking.df(&salt_postings), salt_idf });
    debug.print("chicken: df={d}, IDF={d:.3}\n", .{ ranking.df(&chicken_postings), chicken_idf });
    debug.print("pasta:   df={d}, IDF={d:.3}\n", .{ ranking.df(&pasta_postings), pasta_idf });
    debug.print("truffle: df={d}, IDF={d:.3}\n", .{ ranking.df(&truffle_postings), truffle_idf });
}

test "stop words are filtered and title phrase is indexed" {
    const allocator = testing.allocator;

    const source =
        \\# The Best Scrambled Eggs
        \\
        \\## tags
        \\breakfast, easy
        \\
        \\## ingredients
        \\- eggs
        \\- butter or oil
    ;

    var parser = markdown.Parser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var recipe_parser = recipeParser.RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const recipe_data = try recipe_parser.parse(lines);

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();
    try ri.indexDocument(.{ .document_id = 0, .data = recipe_data });

    // Stop words should NOT be in the index
    try testing.expect(ri.dictionary.get("the") == null);
    try testing.expect(ri.dictionary.get("or") == null);

    // Regular words should be indexed
    try testing.expect(ri.dictionary.get("best") != null);
    try testing.expect(ri.dictionary.get("scrambled") != null);
    try testing.expect(ri.dictionary.get("eggs") != null);
    try testing.expect(ri.dictionary.get("butter") != null);
    try testing.expect(ri.dictionary.get("oil") != null);

    // Title phrase should be indexed (normalized, lowercase)
    const title_phrase_postings = ri.dictionary.get("the best scrambled eggs");
    try testing.expect(title_phrase_postings != null);

    // Verify title phrase has the correct field
    const posting_item = title_phrase_postings.?.docs.items[0];
    try testing.expect(posting_item.fields.contains(.title_phrase));
    try testing.expect(!posting_item.fields.contains(.title)); // phrase is not word

    // Verify individual title words have .title field
    const best_postings = ri.dictionary.get("best").?;
    try testing.expect(best_postings.docs.items[0].fields.contains(.title));
}
