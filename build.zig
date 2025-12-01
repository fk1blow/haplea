const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Executable
    const exe = b.addExecutable(.{
        .name = "haplea",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests for markdown parser module
    const markdown_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/markdown/parser.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_markdown_tests = b.addRunArtifact(markdown_tests);

    // Tests for recipe parser module
    const recipe_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/recipe_parser.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_recipe_tests = b.addRunArtifact(recipe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_markdown_tests.step);
    test_step.dependOn(&run_recipe_tests.step);
}
