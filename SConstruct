import os
import sys
from SCons.Script import Variables, EnumVariable, BoolVariable, Help, Environment, SConscript, Glob, Default, Exit, ARGUMENTS

# 1. Option Settings
# These options allow you to specify the platform, target, and whether to use MinGW on Windows when running the SCons command.
opts = Variables([], ARGUMENTS)
opts.Add(EnumVariable("platform", "Platform to build for", sys.platform, allowed_values=("windows", "linux", "macos", "android", "ios")))
opts.Add(EnumVariable("target", "Compilation target", "template_debug", allowed_values=("template_debug", "template_release")))
opts.Add(BoolVariable("use_mingw", "Use MinGW on Windows", False))

# 2. Initialize the environment
# The environment is where we will set our compilation flags and other settings. We also generate help text for the options we defined.
env = Environment(variables=opts)
Help(opts.GenerateHelpText(env))

# 3. Locate godot-cpp
# Adjust this path if your godot-cpp folder has a different name.
# Note: The SConstruct file should be in the same directory as the godot-cpp folder for this to work.
godot_cpp_path = "godot-cpp"
if not os.path.exists(godot_cpp_path):
    print(f"Error: The folder was not found. '{godot_cpp_path}'.")
    Exit(1)

# 4. Configure flags according to the platform
# These flags are examples and may need to be adjusted based on your specific needs and the requirements of the godot-cpp library.
if env["platform"] == "windows" :
    env.Append(CCFLAGS=["/FS"])
    env.Append(CPPFLAGS=["/EHsc"])
elif env["platform"] == "linux":
    env.Append(CCFLAGS=["-fPIC", "-O3"])

# 5. Load the godot-cpp configuration
# This imports the necessary libraries and paths from the godot-cpp folder
# The SConscript file in the godot-cpp folder should be set up to export the necessary variables (like include paths and library paths) to this main SConstruct file.
SConscript(os.path.join(godot_cpp_path, "SConstruct"), exports="env")


# For each folder from which we want to create a library, we add this code...
# You can add as many folders as you want, just make sure to create the corresponding folder in the src directory and add your .cpp files there.

modules = ["LogFileWriter","RandomMovementComponent","RotatingMovementComponent","ProjectileMovementComponent","FollowingBodyMovementComponent"];

# Note: The name of the library will be the same as the folder name, so make sure to name your folders accordingly. The output file will be named like this: "lib_name.platform.target.extension" (e.g., "TestingClasses.windows.template_debug.dll").
for module in modules :

    # 6. Define sources from the module folder
    # This will include all .cpp files in the specified folder. Make sure to create the corresponding folder in the src directory and add your .cpp files there.
    sources = Glob(f"src/{module}/*.cpp")

    # Output file name (the one you will put in your .gdextension)
    # The library name is set to the module name, and the suffix is determined based on the platform. The final output file will be named like this: "lib_name.platform.target.extension" (e.g., "TestingClasses.windows.template_debug.dll").
    lib_name = module
    lib_suffix = ""

    # Setting the suffix depending on the platform
    # The suffix is important because it determines the type of library that will be generated. On Windows, we use .dll for dynamic libraries, on macOS we use .dylib, and on Linux we use .so. This ensures that the generated library is compatible with the target platform.
    if env["platform"] == "windows":
        lib_suffix = ".dll"
    elif env["platform"] == "macos":
        lib_suffix = ".dylib"
    else:
        lib_suffix = ".so"

    # 7. Binary Construction
    # This is where we actually create the shared library using the sources we defined. The target name includes the platform and target to ensure that the output file is correctly named and can be easily identified.
    library = env.SharedLibrary(
        target=f"main/bin/{lib_name}.{env['platform']}.{env['target']}{lib_suffix}",
        source=sources,
        LIBPREFIX=""
    )

    # 8. Link with godot-cpp
    # This step is crucial as it links the generated library with the godot-cpp library, ensuring that all necessary symbols are resolved and that the library can be used in Godot. The exact libraries to link against may vary based on your specific setup and the requirements of your project.
    Default(library)

# ====================================================================================
