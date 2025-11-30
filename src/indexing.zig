const std = @import("std");

const Posting = struct { document_id: u32, term_frequency: u8, weight: u8 };

const PostingList = struct {
    allocator: std.mem.Allocator,
    postings: std.ArrayList(Posting),

    pub fn init(allocator: std.mem.Allocator) PostingList {
        return .{
            .allocator = allocator,
            .postings = std.ArrayList(Posting){},
        };
    }

    pub fn deinit(self: *PostingList) void {
        self.postings.deinit(self.allocator);
    }

    pub fn append(self: *PostingList, item: Posting) !void {
        try self.postings.append(self.allocator, item);
    }
};

pub const InvertedIndex = struct {
    allocator: std.mem.Allocator,
    index: std.StringHashMap(PostingList),

    pub fn init(allocator: std.mem.Allocator) InvertedIndex {
        return InvertedIndex{ .allocator = allocator, .index = std.StringHashMap(PostingList).init(allocator) };
    }

    pub fn deinit(self: *InvertedIndex) void {
        var it = self.index.iterator();
        while (it.next()) |entry| {
            // deallocate the key of the hash
            self.allocator.free(entry.key_ptr.*);
            // deallocate the posting list
            entry.value_ptr.deinit();
        }
        self.index.deinit();
    }

    pub fn addPosting(self: *InvertedIndex, term: []const u8, posting: Posting) !void {
        const gop = try self.index.getOrPut(term);
        if (!gop.found_existing) {
            // clone the term
            gop.key_ptr.* = try self.allocator.dupe(u8, term);
            gop.value_ptr.* = PostingList.init(self.allocator);
        }
        try gop.value_ptr.append(posting);
    }

    pub fn getPosting(self: *InvertedIndex, term: []const u8) ?PostingList {
        const value = self.index.get(term);
        return value;
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    var index = InvertedIndex.init(allocator);
    defer index.deinit();

    // try index.addPosting("pasta", .{ .document_id = 12, .term_frequency = 6 });
    try index.addPosting("pasta", .{ .document_id = 39, .term_frequency = 2, .weight = 0b010 });
    try index.addPosting("pasta", .{ .document_id = 2, .term_frequency = 1, .weight = 0b001 });
    // try index.addPosting("pasta", 43, 2);

    if (index.getPosting("pasta")) |value| {
        for (value.postings.items) |item| {
            std.debug.print("found: {any} \n", .{item});
        }
    }

    // var ngram = try Ngram.init("salad", allocator);
    // defer ngram.deinit();

    // $$salad^^ (9 chars) -> 7 trigrams
    // $$s, $sa, sal, ala, lad, ad^, d^^
    // try std.testing.expectEqual(@as(usize, 7), ngram.trigrams.items.len);
}
