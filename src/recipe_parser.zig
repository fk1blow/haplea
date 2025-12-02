const std = @import("std");
const mem = std.mem;
const markdown = @import("markdown/parser.zig");
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
    title: std.ArrayList([]const u8),
    tags: std.ArrayList([]const u8),
    ingredients: std.ArrayList([]const u8),

    pub fn init(allocator: mem.Allocator) RecipeData {
        return .{
            .allocator = allocator,
            .title = std.ArrayList([]const u8){},
            .tags = std.ArrayList([]const u8){},
            .ingredients = std.ArrayList([]const u8){},
        };
    }

    pub fn deinit(self: *RecipeData) void {
        for (self.title.items) |item| {
            self.allocator.free(item);
        }
        for (self.tags.items) |item| {
            self.allocator.free(item);
        }
        for (self.ingredients.items) |item| {
            self.allocator.free(item);
        }
        self.title.deinit(self.allocator);
        self.tags.deinit(self.allocator);
        self.ingredients.deinit(self.allocator);
    }
};

pub const RecipeParser = struct {
    allocator: mem.Allocator,
    data: RecipeData,
    state: ExtractionState,

    pub fn init(allocator: mem.Allocator) RecipeParser {
        return .{
            .allocator = allocator,
            .data = RecipeData.init(allocator),
            .state = ExtractionState{},
        };
    }

    pub fn deinit(self: *RecipeParser) void {
        self.data.deinit();
    }

    pub fn parse(self: *RecipeParser, lines: []const Line) !RecipeData {
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

    fn validate(self: *RecipeParser) !void {
        if (!self.state.seen_title or self.data.title.items.len == 0) {
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

    fn handleHeading(self: *RecipeParser, line: Line) !void {
        const heading_text = MarkdownUtils.stripHeading(line.text);

        if (line.type.Heading.level == 1) {
            self.state.transition(.Title);
            var iter = mem.tokenizeScalar(u8, heading_text, ' ');
            while (iter.next()) |word| {
                try self.appendToCurrentSection(word);
            }
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

    fn handleList(self: *RecipeParser, line: Line) !void {
        const line_stripped = MarkdownUtils.stripListMarker(line.text);
        var iter = mem.tokenizeAny(u8, line_stripped, ",;. ");
        while (iter.next()) |word| {
            if (word.len == 0) continue;
            try self.appendToCurrentSection(word);
        }
    }

    fn handleParagraph(self: *RecipeParser, line: Line) !void {
        var iter = mem.tokenizeAny(u8, line.text, ",;. ");
        while (iter.next()) |word| {
            if (word.len == 0) continue;
            try self.appendToCurrentSection(word);
        }
    }

    fn appendToCurrentSection(self: *RecipeParser, word: []const u8) !void {
        const trimmed = mem.trim(u8, word, " \t\r\n,.;");
        if (trimmed.len == 0) return; // Skip empty tokens

        const normalized = try std.ascii.allocLowerString(self.allocator, trimmed);

        switch (self.state.current) {
            .Title => try self.data.title.append(self.allocator, normalized),
            .Ingredients => try self.data.ingredients.append(self.allocator, normalized),
            .Tags => try self.data.tags.append(self.allocator, normalized),
            else => self.allocator.free(normalized),
        }
    }
};

test "RecipeParser - basic parsing" {
    const allocator = std.testing.allocator;

    const source =
        \\# Scrambled Eggs
        \\
        \\## tags
        \\breakfast, Easy
        \\
        \\## ingredients
        \\- eggs
        \\- butter
        \\- ham, or bacon
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 2), data.title.items.len);
    try std.testing.expectEqualStrings("scrambled", data.title.items[0]);
    try std.testing.expectEqualStrings("eggs", data.title.items[1]);
    try std.testing.expectEqual(@as(usize, 2), data.tags.items.len);
    try std.testing.expectEqualStrings("breakfast", data.tags.items[0]);
    try std.testing.expectEqualStrings("easy", data.tags.items[1]);
    try std.testing.expectEqual(@as(usize, 5), data.ingredients.items.len);
    try std.testing.expectEqualStrings("eggs", data.ingredients.items[0]);
    try std.testing.expectEqualStrings("butter", data.ingredients.items[1]);
    try std.testing.expectEqualStrings("ham", data.ingredients.items[2]);
    try std.testing.expectEqualStrings("or", data.ingredients.items[3]);
    try std.testing.expectEqualStrings("bacon", data.ingredients.items[4]);
}

test "RecipeParser - case insensitive headings" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## TAGS
        \\test
        \\## Ingredients
        \\item
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 1), data.title.items.len);
    try std.testing.expectEqualStrings("recipe", data.title.items[0]);
    try std.testing.expect(data.tags.items.len > 0);
    try std.testing.expect(data.ingredients.items.len > 0);
}

test "RecipeParser - exact match prevents substring false positives" {
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

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 1), data.title.items.len);
    try std.testing.expectEqualStrings("recipe", data.title.items[0]);
    // "hashtags" should match due to substring, but "tags" should override with exact match
    try std.testing.expectEqual(@as(usize, 2), data.tags.items.len);
    try std.testing.expectEqualStrings("social", data.tags.items[0]);
    try std.testing.expectEqualStrings("real", data.tags.items[1]);
}

test "RecipeParser - mixed list and paragraph format" {
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

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 1), data.title.items.len);
    try std.testing.expectEqualStrings("recipe", data.title.items[0]);
    try std.testing.expectEqual(@as(usize, 4), data.tags.items.len);
    try std.testing.expectEqual(@as(usize, 3), data.ingredients.items.len);
}

test "RecipeParser - missing title error" {
    const allocator = std.testing.allocator;

    const source =
        \\## tags
        \\test
        \\## ingredients
        \\item
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();

    const result = recipe_parser.parse(lines);
    try std.testing.expectError(RecipeError.MissingTitle, result);
}

test "RecipeParser - missing sections error" {
    const allocator = std.testing.allocator;

    const source = "# Recipe Title\n";

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();

    const result = recipe_parser.parse(lines);
    try std.testing.expectError(RecipeError.MissingTags, result);
}

test "RecipeParser - empty sections error" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## tags
        \\## ingredients
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();

    const result = recipe_parser.parse(lines);
    try std.testing.expectError(RecipeError.EmptyTags, result);
}

test "RecipeParser - multi-word title" {
    const allocator = std.testing.allocator;

    const source =
        \\# Easy Scrambled Eggs Recipe
        \\## tags
        \\breakfast
        \\## ingredients
        \\eggs
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 4), data.title.items.len);
    try std.testing.expectEqualStrings("easy", data.title.items[0]);
    try std.testing.expectEqualStrings("scrambled", data.title.items[1]);
    try std.testing.expectEqualStrings("eggs", data.title.items[2]);
    try std.testing.expectEqualStrings("recipe", data.title.items[3]);
}

test "RecipeParser - title with multiple spaces" {
    const allocator = std.testing.allocator;

    const source =
        \\# Hello   World
        \\## tags
        \\test
        \\## ingredients
        \\item
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    // tokenizeScalar skips empty tokens from multiple spaces
    try std.testing.expectEqual(@as(usize, 2), data.title.items.len);
    try std.testing.expectEqualStrings("hello", data.title.items[0]);
    try std.testing.expectEqualStrings("world", data.title.items[1]);
}

test "RecipeParser - title with special characters" {
    const allocator = std.testing.allocator;

    const source =
        \\# Grandma's Apple Pie
        \\## tags
        \\dessert
        \\## ingredients
        \\apples
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    try std.testing.expectEqual(@as(usize, 3), data.title.items.len);
    try std.testing.expectEqualStrings("grandma's", data.title.items[0]);
    try std.testing.expectEqualStrings("apple", data.title.items[1]);
    try std.testing.expectEqualStrings("pie", data.title.items[2]);
}

test "RecipeParser - lists and paragraphs both split into words" {
    const allocator = std.testing.allocator;

    const source =
        \\# Recipe
        \\## tags
        \\quick and easy
        \\## ingredients
        \\- olive oil
    ;

    var md_parser = markdown.Parser.init(allocator, source);
    defer md_parser.deinit();
    const lines = try md_parser.parse();

    var recipe_parser = RecipeParser.init(allocator);
    defer recipe_parser.deinit();
    const data = try recipe_parser.parse(lines);

    // Paragraph splits into words
    try std.testing.expectEqual(@as(usize, 3), data.tags.items.len);
    try std.testing.expectEqualStrings("quick", data.tags.items[0]);
    try std.testing.expectEqualStrings("and", data.tags.items[1]);
    try std.testing.expectEqualStrings("easy", data.tags.items[2]);

    // List also splits into words
    try std.testing.expectEqual(@as(usize, 2), data.ingredients.items.len);
    try std.testing.expectEqualStrings("olive", data.ingredients.items[0]);
    try std.testing.expectEqualStrings("oil", data.ingredients.items[1]);
}
