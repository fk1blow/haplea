const std = @import("std");
const print = std.debug.print;

pub const Ngram = struct {
    const pad_left = "$$";
    const pad_right = "^^";

    padded_text: []const u8,
    trigrams: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(text: []const u8, allocator: std.mem.Allocator) !Ngram {
        const padded_text = try padText(text, allocator);
        errdefer allocator.free(padded_text);

        const trigrams = try generateTrigrams(text, allocator);

        return Ngram{ .padded_text = padded_text, .trigrams = trigrams, .allocator = allocator };
    }

    pub fn deinit(self: *Ngram) void {
        for (self.trigrams.items) |trigram| {
            self.allocator.free(trigram);
        }
        self.trigrams.deinit(self.allocator);
        self.allocator.free(self.padded_text);
    }

    fn padText(text: []const u8, allocator: std.mem.Allocator) ![]const u8 {
        return try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ pad_left, text, pad_right });
    }

    pub fn generateTrigrams(text: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
        var parts = std.ArrayList([]const u8){};

        if (text.len < 3) return parts;

        const padded_text = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ pad_left, text, pad_right });
        defer allocator.free(padded_text);

        // $$cat^^ -> $$c, $ca, cat, at^, t^^
        // $$soup^^ -> $$s, $so, sou, oup, up^, p^^
        const sliding_window_length = padded_text.len - 2;
        for (0..sliding_window_length) |index| {
            const part = try allocator.dupe(u8, padded_text[index .. index + 3]);
            try parts.append(allocator, part);
        }

        return parts;
    }
};

test "generateTrigrams - basic word" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("cat", allocator);
    defer {
        for (trigrams.items) |item| allocator.free(item);
        trigrams.deinit(allocator);
    }

    try std.testing.expectEqual(@as(usize, 5), trigrams.items.len);
    try std.testing.expectEqualStrings("$$c", trigrams.items[0]);
    try std.testing.expectEqualStrings("$ca", trigrams.items[1]);
    try std.testing.expectEqualStrings("cat", trigrams.items[2]);
    try std.testing.expectEqualStrings("at^", trigrams.items[3]);
    try std.testing.expectEqualStrings("t^^", trigrams.items[4]);
}

test "generateTrigrams - longer word" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("soup", allocator);
    defer {
        for (trigrams.items) |item| allocator.free(item);
        trigrams.deinit(allocator);
    }

    // $$soup^^ -> $$s, $so, sou, oup, up^, p^^
    try std.testing.expectEqual(@as(usize, 6), trigrams.items.len);
    try std.testing.expectEqualStrings("$$s", trigrams.items[0]);
    try std.testing.expectEqualStrings("p^^", trigrams.items[5]);
}

test "generateTrigrams - empty string" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("", allocator);
    defer trigrams.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 0), trigrams.items.len);
}

test "generateTrigrams - single character" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("a", allocator);
    defer trigrams.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 0), trigrams.items.len);
}

test "generateTrigrams - two characters" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("ab", allocator);
    defer trigrams.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 0), trigrams.items.len);
}

test "generateTrigrams - three characters (minimum)" {
    const allocator = std.testing.allocator;
    var trigrams = try Ngram.generateTrigrams("abc", allocator);
    defer {
        for (trigrams.items) |item| allocator.free(item);
        trigrams.deinit(allocator);
    }

    // $$abc^^ -> $$a, $ab, abc, bc^, c^^
    try std.testing.expectEqual(@as(usize, 5), trigrams.items.len);
}
