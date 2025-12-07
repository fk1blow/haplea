const std = @import("std");
const httpz = @import("httpz");

pub const Asset = struct {
    content: []const u8,
    content_type: httpz.ContentType,
};

// Embedded frontend assets (from src/static/)
const index_html = @embedFile("static/index.html");
const index_js = @embedFile("static/assets/index.js");
const index_css = @embedFile("static/assets/index.css");

// Asset definitions
const html_asset = Asset{ .content = index_html, .content_type = .HTML };
const js_asset = Asset{ .content = index_js, .content_type = .JS };
const css_asset = Asset{ .content = index_css, .content_type = .CSS };

// Static map of paths to assets
const assets = std.StaticStringMap(Asset).initComptime(.{
    .{ "/", html_asset },
    .{ "/index.html", html_asset },
    .{ "/assets/index.js", js_asset },
    .{ "/assets/index.css", css_asset },
});

/// Get an embedded asset by path
pub fn get(path: []const u8) ?Asset {
    return assets.get(path);
}

/// Get index.html (for SPA fallback)
pub fn getIndex() Asset {
    return html_asset;
}
