const std = @import("std");

pub const PostingField = enum(u8) {
    title,
    tags,
    ingredients,

    pub fn getWeight(self: PostingField) u8 {
        return switch (self) {
            .title => 4,
            .tags => 2,
            .ingredients => 1,
        };
    }
};

pub const PostingItem = struct {
    document_id: u32,
    term_frequency: u8,
    source_field: PostingField,

    pub fn getWeight(self: PostingItem) u8 {
        var w: u8 = 0;
        var iter = self.source_field.iterator();
        while (iter.next()) |field| {
            w += field.weight();
        }
        return w;
    }
};

pub const PostingList = struct {
    allocator: std.mem.Allocator,
    postings: std.ArrayList(PostingItem),

    pub fn init(allocator: std.mem.Allocator) PostingList {
        return .{ .allocator = allocator, .postings = std.ArrayList(PostingItem){} };
    }

    pub fn deinit(self: *PostingList) void {
        self.postings.deinit(self.allocator);
    }

    pub fn append(self: *PostingList, item: PostingItem) !void {
        try self.postings.append(self.allocator, item);
    }
};
