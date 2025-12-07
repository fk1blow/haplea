const std = @import("std");
const is_test = @import("builtin").is_test;
const Allocator = std.mem.Allocator;

pub const AppPathsError = error{HomePathNotFound};

pub fn getDocumentsPath(gpa: Allocator) ![]const u8 {
    const home_path = getEnv("HOME") orelse return AppPathsError.HomePathNotFound;
    return std.fmt.allocPrint(gpa, "{s}{s}", .{ home_path, DocumentsPath });
}

const DocumentsPath = "/Documents/Haplea";

fn getEnv(key: []const u8) ?[]const u8 {
    if (is_test) {
        if (std.mem.eql(u8, key, "HOME")) return "/Users/someone";
        return null;
    }
    return std.posix.getenv(key);
}

test "getDocumentsPath returns path" {
    const allocator = std.testing.allocator;

    const path = try getDocumentsPath(allocator);
    defer allocator.free(path);

    try std.testing.expect(path.len > 0);
    try std.testing.expect(std.mem.eql(u8, path, "/Users/someone/Documents/Haplea"));
}
