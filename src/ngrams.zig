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

test "Ngram - initial test" {
    const allocator = std.testing.allocator;
    // const foo = "soup";
    const foo = "cat";

    var ngram = try Ngram.init(foo, allocator);
    defer ngram.deinit();

    for (ngram.trigrams.items) |item| {
        print("{s} \n", .{item});
    }
    // print("ngram received: {any}\n", .{ngram});
}
