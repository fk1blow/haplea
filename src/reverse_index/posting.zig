const std = @import("std");

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
    document_id: u32,
    term_frequency: u8,
    source_field: Field,

    pub fn getWeight(self: Posting) u8 {
        var w: u8 = 0;
        var iter = self.source_field.iterator();
        while (iter.next()) |field| {
            w += field.weight();
        }
        return w;
    }
};

pub const Postings = struct {
    allocator: std.mem.Allocator,
    items: std.ArrayList(Posting),

    pub fn init(allocator: std.mem.Allocator) Postings {
        return .{ .allocator = allocator, .items = std.ArrayList(Posting){} };
    }

    pub fn deinit(self: *Postings) void {
        self.items.deinit(self.allocator);
    }

    pub fn append(self: *Postings, item: Posting) !void {
        try self.items.append(self.allocator, item);
    }
};
