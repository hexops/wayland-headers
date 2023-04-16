const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "wayland-headers",
        .root_source_file = .{ .path = "stub.c" },
        .target = target,
        .optimize = optimize,
    });

    lib.installHeadersDirectory("include", ".");
    lib.installHeadersDirectory("wayland-generated", ".");

    b.installArtifact(lib);
}
