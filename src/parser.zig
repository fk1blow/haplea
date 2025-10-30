const std = @import("std");

pub const Parser = struct {
    position: usize,
    source: []const u8,

    pub fn init(source: []const u8) Parser {
        return Parser{ .source = source, .position = 0 };
    }

    fn advance(self: *Parser) void {
        self.position += 1;
    }

    fn can_advance(self: *Parser) bool {
        return self.position < self.source.len;
    }

    pub fn scan(self: *Parser) void {
        std.debug.print("- should scan: \n", .{});

        const Starting = enum { Heading, Undefined };

        while (self.can_advance()) {
            const starting: Starting = switch (self.source[self.position]) {
                '#' => .Heading,
                else => .Undefined,
            };

            switch (starting) {
                .Heading => {
                    var level: i8 = 0;
                    while (level <= 5 and self.source[self.position] == '#') {
                        level += 1;
                        self.advance();
                    }

                    if (self.source[self.position] == ' ') {
                        self.advance();
                    }

                    const text_start = self.position;
                    while (self.can_advance() and self.source[self.position] != '\n') {
                        self.advance();
                    }
                    const text = self.source[text_start..self.position];

                    std.debug.print("heading level: {} \n", .{level});
                    std.debug.print("heading text: <{s}> \n", .{text});
                },

                .Undefined => {},
            }

            self.advance();
        }
    }
};

// Tests
test "parse initial" {
    var parser = Parser.init("# Recipe Title"); // 14 chars len
    parser.scan();
}

test "parse multiline" {
    const input =
        \\ # Recipe Title
        \\
    ;
    var parser = Parser.init(input);
    parser.scan();
}

test "parse recipe with ingredients" {
    const input =
        \\# Scrambled Eggs
        \\
        \\Easy, fast and good recipe.
        \\
        \\## ingredients
        \\
        \\- eggs
        \\- cheese
    ;

    var parser = Parser.init(input);
    parser.scan();
}

test "parse full recipe" {
    const input =
        \\# Scrambled Eggs
        \\
        \\Easy, fast and good recipe.
        \\
        \\## tags
        \\
        \\breakfast, eggs, fast food
        \\
        \\## ingredients
        \\
        \\- eggs
        \\- onion or leek(praz)
        \\- cheese
        \\- salt
        \\- pepper
        \\
        \\## instructions
        \\
        \\how to do it...
    ;

    var parser = Parser.init(input);
    parser.scan();
}

// =============================================================

// TODO define a Parser struct and a `parse` or `scan` method
pub fn parse(markdown: []const u8) void {
    var i: usize = 0;

    const Starting = enum {
        Heading,
        // ListItem,
        // Text,
        // Newline,
        Undefined,
    };

    while (i < markdown.len) {
        const c = markdown[i];

        // Check what we're starting
        // const starting: Starting = blk: {
        //     if (c == '#') {
        //         break :blk .Heading;
        //     } else if (c == '-' and (i == 0 or markdown[i - 1] == '\n')) {
        //         break :blk .ListItem;
        //     } else if (c == '\n') {
        //         break :blk .Newline;
        //     } else {
        //         break :blk .Text;
        //     }
        // };
        const starting: Starting = switch (c) {
            '#' => .Heading,
            else => .Undefined,
        };

        // For now, just consume the character
        // In the future, you'll build tokens here
        switch (starting) {
            .Heading => {
                // Count the number of # symbols to determine heading level
                var level: u8 = 0;
                while (i < markdown.len and markdown[i] == '#' and level <= 6) : (i += 1) {
                    level += 1;
                }
                std.debug.print("Found heading level {d}\n", .{level});
            },
            .Undefined => {
                std.debug.print("Found undefined item \n", .{});
            },
            // .ListItem => {
            //     std.debug.print("Found list item\n", .{});
            //     i += 1;
            // },
            // .Newline => {
            //     std.debug.print("Found newline\n", .{});
            //     i += 1;
            // },
            // .Text => {
            //     // Consume until end of line or end of string
            //     const start = i;
            //     while (i < markdown.len and markdown[i] != '\n') : (i += 1) {}
            //     std.debug.print("Found text: {s}\n", .{markdown[start..i]});
            // },
        }
    }
}

// test "parse simple heading" {
//     const input = "# Recipe Title";
//     parse(input);
// }
