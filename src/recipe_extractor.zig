const std = @import("std");
const mem = std.mem;
const markdown = @import("markdown.zig");
const Line = markdown.Line;
const LineType = markdown.LineType;

pub const RecipeError = error{
    MissingTitle,
    MissingTags,
    MissingIngredients,
    EmptyTags,
    EmptyIngredients,
};

const MarkdownUtils = struct {
    pub fn stripHeading(line: []const u8) []const u8 {
        var i: usize = 0;
        while (i < line.len and (line[i] == '#' or line[i] == ' ')) : (i += 1) {}
        return line[i..];
    }

    pub fn stripListMarker(line: []const u8) []const u8 {
        const trimmed = mem.trimLeft(u8, line, " \t");
        var i: usize = 0;
        while (i < trimmed.len and (trimmed[i] == '-' or trimmed[i] == '*' or trimmed[i] == ' ')) : (i += 1) {}
        return trimmed[i..];
    }
};

const ExtractionState = struct {
    pub const SectionType = enum { None, Title, Ingredients, Tags, Unknown };

    current: SectionType = .None,
    seen_title: bool = false,
    seen_tags: bool = false,
    seen_ingredients: bool = false,

    fn isComplete(self: ExtractionState) bool {
        return self.seen_title and self.seen_ingredients and self.seen_tags;
    }

    fn transition(self: *ExtractionState, to: SectionType) void {
        self.current = to;
        switch (to) {
            .Title => self.seen_title = true,
            .Tags => self.seen_tags = true,
            .Ingredients => self.seen_ingredients = true,
            .None, .Unknown => {},
        }
    }
};

pub const RecipeData = struct {
    allocator: mem.Allocator,
    title: []const u8 = "",
    tags: std.ArrayList([]const u8),
    ingredients: std.ArrayList([]const u8),

    pub fn init(allocator: mem.Allocator) RecipeData {
        return .{
            .allocator = allocator,
            .tags = std.ArrayList([]const u8){},
            .ingredients = std.ArrayList([]const u8){},
        };
    }

    pub fn deinit(self: *RecipeData) void {
        self.tags.deinit(self.allocator);
        self.ingredients.deinit(self.allocator);
    }
};

pub const RecipeExtractor = struct {
    allocator: mem.Allocator,
    data: RecipeData,
    state: ExtractionState,

    pub fn init(allocator: mem.Allocator) RecipeExtractor {
        return .{
            .allocator = allocator,
            .data = RecipeData.init(allocator),
            .state = ExtractionState{},
        };
    }

    pub fn deinit(self: *RecipeExtractor) void {
        self.data.deinit();
    }

    pub fn extract(self: *RecipeExtractor, lines: []const Line) !RecipeData {
        for (lines) |line| {
            if (line.type == .Blank or line.type == .Empty) continue;

            // Handle headings
            if (line.type == .Heading) {
                try self.handleHeading(line);
                continue;
            }

            // Handle content based on current state
            switch (line.type) {
                .List => try self.handleList(line),
                .Paragraph => try self.handleParagraph(line),
                else => {},
            }
        }

        // Validate recipe data
        try self.validate();

        return self.data;
    }

    fn validate(self: *RecipeExtractor) !void {
        if (!self.state.seen_title or self.data.title.len == 0) {
            return RecipeError.MissingTitle;
        }
        if (!self.state.seen_tags) {
            return RecipeError.MissingTags;
        }
        if (!self.state.seen_ingredients) {
            return RecipeError.MissingIngredients;
        }
        if (self.data.tags.items.len == 0) {
            return RecipeError.EmptyTags;
        }
        if (self.data.ingredients.items.len == 0) {
            return RecipeError.EmptyIngredients;
        }
    }

    fn matchesSectionExact(heading: []const u8, needle: []const u8, allocator: mem.Allocator) !bool {
        const heading_trimmed = mem.trim(u8, heading, " \t\r\n");
        const heading_lower = try std.ascii.allocLowerString(allocator, heading_trimmed);
        defer allocator.free(heading_lower);

        const needle_lower = try std.ascii.allocLowerString(allocator, needle);
        defer allocator.free(needle_lower);

        return mem.eql(u8, heading_lower, needle_lower);
    }

    fn matchesSectionSubstring(heading: []const u8, needle: []const u8, allocator: mem.Allocator) !bool {
        const heading_lower = try std.ascii.allocLowerString(allocator, heading);
        defer allocator.free(heading_lower);

        const needle_lower = try std.ascii.allocLowerString(allocator, needle);
        defer allocator.free(needle_lower);

        return mem.indexOf(u8, heading_lower, needle_lower) != null;
    }

    fn handleHeading(self: *RecipeExtractor, line: Line) !void {
        const heading_text = MarkdownUtils.stripHeading(line.text);

        if (line.type.Heading.level == 1) {
            self.data.title = heading_text;
            self.state.transition(.Title);
        } else if (line.type.Heading.level >= 2) {
            // Try exact match first, then substring
            if (try matchesSectionExact(heading_text, "tags", self.allocator)) {
                self.state.transition(.Tags);
            } else if (try matchesSectionExact(heading_text, "ingredients", self.allocator)) {
                self.state.transition(.Ingredients);
            } else if (try matchesSectionSubstring(heading_text, "tags", self.allocator)) {
                self.state.transition(.Tags);
            } else if (try matchesSectionSubstring(heading_text, "ingredients", self.allocator)) {
                self.state.transition(.Ingredients);
            } else {
                self.state.transition(.Unknown);
            }
        }
    }

    fn handleList(self: *RecipeExtractor, line: Line) !void {
        const line_text = MarkdownUtils.stripListMarker(line.text);
        try self.appendToCurrentSection(line_text);
    }

    fn handleParagraph(self: *RecipeExtractor, line: Line) !void {
        var iter = mem.tokenizeAny(u8, line.text, ",");
        while (iter.next()) |token| {
            try self.appendToCurrentSection(token);
        }
    }

    fn appendToCurrentSection(self: *RecipeExtractor, text: []const u8) !void {
        const trimmed = mem.trim(u8, text, " \t\r\n");
        if (trimmed.len == 0) return; // Skip empty tokens

        switch (self.state.current) {
            .Ingredients => try self.data.ingredients.append(self.allocator, trimmed),
            .Tags => try self.data.tags.append(self.allocator, trimmed),
            else => {}, // Ignore content outside tracked sections
        }
    }
};

// Tests
test "RecipeExtractor - basic extraction" {
    const allocator = std.testing.allocator;

    const source =
        \\# Scrambled Eggs
        \\
        \\## tags
        \\breakfast, easy
        \\
        \\## ingredients
        \\- eggs
        \\- butter
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();
    const data = try extractor.extract(lines);

    try std.testing.expectEqualStrings("Scrambled Eggs", data.title);
    try std.testing.expectEqual(@as(usize, 2), data.tags.items.len);
    try std.testing.expectEqualStrings("breakfast", data.tags.items[0]);
    try std.testing.expectEqualStrings("easy", data.tags.items[1]);
    try std.testing.expectEqual(@as(usize, 2), data.ingredients.items.len);
    try std.testing.expectEqualStrings("eggs", data.ingredients.items[0]);
    try std.testing.expectEqualStrings("butter", data.ingredients.items[1]);
}

test "RecipeExtractor - case insensitive headings" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## TAGS
        \\test
        \\## Ingredients
        \\item
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();
    const data = try extractor.extract(lines);

    try std.testing.expect(data.tags.items.len > 0);
    try std.testing.expect(data.ingredients.items.len > 0);
}

test "RecipeExtractor - exact match prevents substring false positives" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## hashtags
        \\social
        \\## ingredients
        \\item
        \\## tags
        \\real
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();
    const data = try extractor.extract(lines);

    // "hashtags" should match due to substring, but "tags" should override with exact match
    try std.testing.expectEqual(@as(usize, 2), data.tags.items.len);
    try std.testing.expectEqualStrings("social", data.tags.items[0]);
    try std.testing.expectEqualStrings("real", data.tags.items[1]);
}

test "RecipeExtractor - mixed list and paragraph format" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## tags
        \\- tag1
        \\- tag2
        \\tag3, tag4
        \\## ingredients
        \\item1, item2
        \\- item3
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();
    const data = try extractor.extract(lines);

    try std.testing.expectEqual(@as(usize, 4), data.tags.items.len);
    try std.testing.expectEqual(@as(usize, 3), data.ingredients.items.len);
}

test "RecipeExtractor - missing title error" {
    const allocator = std.testing.allocator;

    const source =
        \\## tags
        \\test
        \\## ingredients
        \\item
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();

    const result = extractor.extract(lines);
    try std.testing.expectError(RecipeError.MissingTitle, result);
}

test "RecipeExtractor - missing sections error" {
    const allocator = std.testing.allocator;

    const source = "# Recipe Title\n";

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();

    const result = extractor.extract(lines);
    try std.testing.expectError(RecipeError.MissingTags, result);
}

test "RecipeExtractor - empty sections error" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## tags
        \\## ingredients
    ;

    var parser = markdown.MarkdownParser.init(allocator, source);
    defer parser.deinit();
    const lines = try parser.parse();

    var extractor = RecipeExtractor.init(allocator);
    defer extractor.deinit();

    const result = extractor.extract(lines);
    try std.testing.expectError(RecipeError.EmptyTags, result);
}
