const std = @import("std");

// TODO rename
pub const Field = enum(u8) {
    title,
    tags,
    ingredients,

    pub fn getWeight(self: Field) u8 {
        return switch (self) {
            .title => 4,
            .tags => 2,
            .ingredients => 1,
        };
    }
};

pub const Posting = struct {
    doc_id: u32,
    term_frequency: u8,
    field: Field,

    pub fn init(id: u32, field: Field) Posting {
        return Posting{ .doc_id = id, .term_frequency = 0, .field = field };
    }

    pub fn getWeight(self: Posting) u8 {
        var w: u8 = 0;
        var iter = self.field.iterator();
        while (iter.next()) |field| {
            w += field.weight();
        }
        return w;
    }
};

pub const PostingList = struct {
    allocator: std.mem.Allocator,
    items: std.ArrayList(Posting),

    pub fn init(allocator: std.mem.Allocator) PostingList {
        return .{ .allocator = allocator, .items = std.ArrayList(Posting){} };
    }

    pub fn deinit(self: *PostingList) void {
        self.items.deinit(self.allocator);
    }

    pub fn append(self: *PostingList, item: Posting) !void {
        try self.items.append(self.allocator, item);
    }
};
