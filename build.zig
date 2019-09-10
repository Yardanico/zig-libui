const builtin = @import("builtin");
const Builder = @import("std").build.Builder;


pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("main", "src/main.zig");
    
    exe.setBuildMode(mode);

    // TODO: Add support for Windows + macOS
    const c_system_libs = [_][]const u8{
        "c", "glib-2.0", "gtk-3", 
        "gdk-3", "pango-1.0", "gobject-2.0"
    };

    for (c_system_libs) |lib| {
        exe.linkSystemLibrary(lib);
    }

    exe.addIncludeDir("vendor/include");
    // Prebuilt libui static libraries
    if (mode == builtin.Mode.ReleaseFast) {
        exe.addObjectFile("vendor/static/libuirel.a");
    }
    else {
        exe.addObjectFile("vendor/static/libui.a");
    }
    

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}