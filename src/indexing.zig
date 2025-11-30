const std = @import("std");
const posting = @import("posting.zig");

pub const InvertedIndex = struct {
    allocator: std.mem.Allocator,
    index: std.StringHashMap(posting.PostingList),

    pub fn init(allocator: std.mem.Allocator) InvertedIndex {
        return InvertedIndex{ .allocator = allocator, .index = std.StringHashMap(posting.PostingList).init(allocator) };
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

    pub fn addPosting(self: *InvertedIndex, term: []const u8, item: posting.PostingItem) !void {
        const gop = try self.index.getOrPut(term);
        if (!gop.found_existing) {
            // clone the term
            gop.key_ptr.* = try self.allocator.dupe(u8, term);
            gop.value_ptr.* = posting.PostingList.init(self.allocator);
        }
        try gop.value_ptr.append(item);
    }

    pub fn getPosting(self: *InvertedIndex, term: []const u8) ?posting.PostingList {
        const value = self.index.get(term);
        return value;
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    var index = InvertedIndex.init(allocator);
    defer index.deinit();

    // try index.addPosting("pasta", .{ .document_id = 12, .term_frequency = 6 });
    try index.addPosting("pasta", .{ .document_id = 39, .term_frequency = 2, .source_field = posting.PostingField.title });
    try index.addPosting("pasta", .{ .document_id = 2, .term_frequency = 2, .source_field = posting.PostingField.ingredients });

    if (index.getPosting("pasta")) |value| {
        for (value.postings.items) |item| {
            std.debug.print("found: {any}, weight: {d} \n", .{ item, item.source_field.getWeight() });
        }
    }
}
