const std = @import("std");
const json = @import("std").json;
const mem = std.mem;

const MarkdownUtils = struct {
    pub fn stripHeading(line: []const u8) []const u8 {
        var i: usize = 0;
        while (i < line.len and (line[i] == '#' or line[i] == ' ')) : (i += 1) {}
        return line[i..];
    }

    pub fn stripListMarker(line: []const u8) []const u8 {
        var i: usize = 0;
        while (i < line.len and (line[i] == '-' or line[i] == '*' or line[i] == ' ')) : (i += 1) {}
        return line[i..];
    }
};

const LineType = union(enum) {
    Blank,
    Empty,
    Paragraph,
    Heading: struct { level: u8 },
    List,
};

const Line = struct {
    type: LineType,
    text: []const u8,
    position: usize,

    fn is_heading(text: []const u8) ?u8 {
        var hash_count: usize = 0;
        var i: u8 = 0;

        while (i < text.len and text[i] == '#') {
            hash_count += 1;
            i += 1;
        }

        if (hash_count >= 1 and hash_count <= 6 and i < text.len and text[i] == ' ')
            return i;
        return null;
    }

    fn is_empty(text: []const u8) bool {
        var i: usize = 0;
        while (i < text.len) : (i += 1) {
            if (text[i] != ' ') return false;
        }
        return true;
    }

    fn is_list(text: []const u8) bool {
        const trimmed = mem.trimLeft(u8, text, " ");
        const indent = text.len - trimmed.len;
        return indent < 4 and mem.startsWith(u8, trimmed, "- ");
    }

    pub fn init(text: []const u8, position: usize) Line {
        const line_type = if (text.len == 0)
            LineType{ .Blank = {} }
        else if (is_empty(text))
            LineType{ .Empty = {} }
        else if (is_heading(text)) |level|
            LineType{ .Heading = .{ .level = level } }
        else if (is_list(text))
            LineType{ .List = {} }
        else
            LineType{ .Paragraph = {} };

        return .{ .type = line_type, .text = text, .position = position };
    }
};

const LineParsingError = error{ SameStateTransition, TransitionToNone, AlreadyComplete };

const LineParsingState = struct {
    pub const CurrentType = enum { None, Title, Ingredients, Tags, Unknown };
    current: CurrentType = .None,

    title: bool = false,
    tags: bool = false,
    ingredients: bool = false,

    fn isComplete(self: LineParsingState) bool {
        return self.title and self.ingredients and self.tags;
    }

    fn transition(self: *LineParsingState, to: CurrentType) LineParsingError!void {
        if (self.isComplete()) {
            return LineParsingError.AlreadyComplete;
        }
        // if (self.current == to) {
        //     return LineParsingError.SameStateTransition;
        // }
        if (to == CurrentType.None) {
            return LineParsingError.TransitionToNone;
        }
        self.current = to;
    }
};

const Block = struct { title: []const u8 = "", tags: std.ArrayList([]const u8), ingredients: std.ArrayList([]const u8) };

pub const Parser = struct {
    allocator: mem.Allocator,
    source: []const u8,
    lines: std.ArrayList(Line),
    block: Block,

    pub fn init(allocator: mem.Allocator, source: []const u8) Parser {
        const block = Block{ .tags = std.ArrayList([]const u8){}, .ingredients = std.ArrayList([]const u8){} };
        const lines = std.ArrayList(Line){};
        return Parser{ .allocator = allocator, .source = source, .lines = lines, .block = block };
    }

    pub fn deinit(self: *Parser) void {
        self.lines.deinit(self.allocator);
        self.block.tags.deinit(self.allocator);
        self.block.ingredients.deinit(self.allocator);
    }

    pub fn parse(self: *Parser) !void {
        try self.classify_lines();
        try self.parse_lines();
    }

    fn classify_lines(self: *Parser) !void {
        var it = std.mem.splitScalar(u8, self.source, '\n');
        var i: usize = 0;
        while (it.next()) |line| : (i += 1) {
            try self.lines.append(self.allocator, Line.init(line, i));
        }
    }

    fn parse_lines(self: *Parser) !void {
        var parsingState = LineParsingState{};

        for (self.lines.items) |line| {
            if (line.type == .Blank or line.type == .Empty) continue;

            // std.debug.print("line, idx: {}, {d}", .{ line.type, index });
            std.debug.print("parsing state: {}, line.type {} \n", .{ parsingState.current, line.type });

            if (line.type == LineType.Heading) {
                const heading_text = MarkdownUtils.stripHeading(line.text);

                if (line.type.Heading.level == 1) {
                    self.block.title = heading_text;
                    try parsingState.transition(.Title);
                } else if (line.type.Heading.level == 2) {
                    if (mem.indexOf(u8, heading_text, "tags")) |_| {
                        try parsingState.transition(.Tags);
                    } else if (mem.indexOf(u8, heading_text, "ingredients")) |_| {
                        try parsingState.transition(.Ingredients);
                    } else {
                        try parsingState.transition(.Unknown);
                    }
                }
            }

            if (line.type == LineType.List) {
                if (parsingState.current == .Ingredients) {
                    const line_text = MarkdownUtils.stripListMarker(line.text);
                    try self.block.ingredients.append(self.allocator, line_text);
                } else if (parsingState.current == .Tags) {
                    const line_text = MarkdownUtils.stripListMarker(line.text);
                    try self.block.tags.append(self.allocator, line_text);
                }
            }

            if (line.type == LineType.Paragraph) {
                if (parsingState.current == .Ingredients) {
                    try self.block.ingredients.append(self.allocator, line.text);
                } else if (parsingState.current == .Tags) {
                    try self.block.tags.append(self.allocator, line.text);
                }
            }
        }

        // std.debug.print("stage: {} \n", .{parsingState.current});
        // std.debug.print("title: {s}, ingredients: {s} \n", .{ self.block.title, self.block.ingredients });
    }
};

test "parse recipe from filesystem" {
    const file = try std.fs.cwd().openFile("docs/recipe-examples/scrambled-eggs-recipe.md", .{});
    defer file.close();
    const content = try file.readToEndAlloc(std.testing.allocator, 1024 * 1024);
    defer std.testing.allocator.free(content);

    var parser = Parser.init(std.testing.allocator, content);
    defer parser.deinit();
    try parser.parse();

    // for (parser.lines.items) |line| {
    //     if (line.type == LineType.Blank) continue;

    //     switch (line.type) {
    //         .Heading => |heading| {
    //             std.debug.print("  {{ .type = .Heading, .level = {d}, .position = {d}, .text = \"{s}\" }}\n", .{ heading.level, line.position, line.text });
    //         },
    //         else => {
    //             std.debug.print("  {{ .type = .{s}, .position = {d}, .text = \"{s}\" }}\n", .{ @tagName(line.type), line.position, line.text });
    //         },
    //     }
    // }

    // std.debug.print("block: {{ .title = \".{s}\", .tags = \".{} }} \n", .{ parser.block.title, parser.block.tags });
    // std.debug.print("block: {{ .title = \".{s}\", .tags = \".{} }} \n", .{ parser.block.title, parser.block.tags });
    // std.debug.print("block = {any}\n", .{parser.block});
    // try json.stringify(parser.block, .{}, std.io.getStdErr().writer());
    // std.debug.print("{}\n", .{parser.block});
    // for (parser.block.ingredients.items) |item| {
    //     std.debug.print("block: {s} \n", .{item});
    // }

    try std.testing.expectEqual(@as(usize, 27), parser.lines.items.len);
}

test "classify lines" {
    const source =
        \\# Splitting
        \\This is
        \\the start
        \\
        \\of a great journey!
        \\## Notes
        \\something something
        \\
        \\## Lists
        \\- first
        \\- second
        \\-thirdish
    ;
    _ = source;
    // const s2 = "\n   ";
    // const s3 = "\n bla bla ";

    // var parser = Parser.init(std.testing.allocator, source ++ s2 ++ s3);
    // defer parser.deinit();
    // try parser.parse();

    // try std.testing.expectEqual(@as(usize, 14), parser.lines.items.len);
}
