const std = @import("std");

pub const Field = enum {
    title,
    tags,
    ingredients,
};

pub const FieldSet = std.EnumSet(Field);

pub const Posting = struct {
    doc_id: u32,
    term_frequency: u8,
    fields: FieldSet,

    pub fn init(id: u32, field: Field) Posting {
        return Posting{
            .doc_id = id,
            .term_frequency = 0,
            .fields = FieldSet.initOne(field),
        };
    }

    pub fn addField(self: *Posting, field: Field) void {
        self.fields.insert(field);
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
