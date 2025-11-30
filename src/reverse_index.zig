const std = @import("std");
const posting = @import("reverse_index/posting.zig");

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

    pub fn addPosting(self: *ReverseIndex, term: []const u8, item: posting.Posting) !void {
        const gop = try self.index.getOrPut(term);
        if (!gop.found_existing) {
            // clone the term
            gop.key_ptr.* = try self.allocator.dupe(u8, term);
            gop.value_ptr.* = posting.PostingList.init(self.allocator);
        }
        try gop.value_ptr.append(item);
    }

    pub fn indexDocument(self: *ReverseIndex) {
        // TODO
    }
};

test "initial" {
    const allocator = std.testing.allocator;

    var ri = ReverseIndex.init(allocator);
    defer ri.deinit();

    try ri.addPosting("pasta", .{ .document_id = 39, .term_frequency = 2, .source_field = posting.SourceField.title });
    try ri.addPosting("pasta", .{ .document_id = 2, .term_frequency = 2, .source_field = posting.SourceField.ingredients });

    if (ri.index.get("pasta")) |postings| {
        for (postings.items.items) |item| {
            std.debug.print("found: {any}, weight: {d} \n", .{ item, item.source_field.getWeight() });
        }
    }
}
