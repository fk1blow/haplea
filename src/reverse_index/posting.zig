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

pub const Postings = struct {
    allocator: std.mem.Allocator,
    docs: std.ArrayList(Posting),

    pub fn init(allocator: std.mem.Allocator) Postings {
        return .{ .allocator = allocator, .docs = std.ArrayList(Posting){} };
    }

    pub fn deinit(self: *Postings) void {
        self.docs.deinit(self.allocator);
    }

    pub fn append(self: *Postings, item: Posting) !void {
        try self.docs.append(self.allocator, item);
    }
};
