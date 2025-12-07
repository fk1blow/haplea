const std = @import("std");
const httpz = @import("httpz");
const assets = @import("embedded_assets.zig");

const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("Haplea starting...\n", .{});

    // Initialize HTTP server (void context - no shared state)
    var server = try httpz.Server(void).init(allocator, .{
        .port = 3000,
        .address = "127.0.0.1",
    }, {});
    defer {
        server.stop();
        server.deinit();
    }

    // Setup routes
    var router = try server.router(.{});

    // Serve static files for all paths
    router.get("/*", serveStatic, .{});

    print("Server running at http://127.0.0.1:3000\n", .{});

    // Start the server (blocking)
    try server.listen();
}

fn serveStatic(req: *httpz.Request, res: *httpz.Response) !void {
    const path = req.url.path;

    if (assets.get(path)) |asset| {
        res.content_type = asset.content_type;
        res.body = asset.content;
    } else {
        // SPA fallback: serve index.html for unknown routes
        const index = assets.getIndex();
        res.content_type = index.content_type;
        res.body = index.content;
    }
}
