/**
 * @file 2am-builder.h
 * @brief 2AM Build System - A single-header C build system for when it's 2AM
 *
 * A minimal, pure-C build system that compiles when nothing else will.
 * Perfect for simple to medium C projects where you just want things to work.
 *
 * ...Yes, you compile this program to build & compile your program
 * And if it still doesn't work: ¯\_(o_o)_/¯
 *
 * @warning This is NOT a replacement for Make/CMake or any other build tool!
 * @note This header must live in the project root.
 *
 * Moving it into subdirectories will break relative paths
 * and summon confusing build behavior.
 *
 * If you think "it should still work" — it won’t.
 *
 * ###########################################################################
 *
 * COMMON COMPILER FLAGS CHEATSHEET:
 *
 * == DEBUGGING ==
 * -g              Add debug symbols (for GDB)
 * -ggdb           Extra debug info for GDB
 * -O0             No optimization (easier debugging)
 *
 * == WARNINGS ==
 * -Wall           Enable most warnings
 * -Wextra         Extra warnings
 * -Werror         Treat warnings as errors
 * -Wpedantic      Strict ISO C compliance
 * -Wconversion    Warn on implicit type conversions
 *
 * == OPTIMIZATION ==
 * -O1             Basic optimization
 * -O2             Good optimization (default for release)
 * -O3             Aggressive optimization
 * -Os             Optimize for size
 * -Ofast          Fast math (breaks strict standards)
 *
 * == SHARED LIBRARIES ==
 * -fPIC           Position Independent Code (required for .so)
 * -shared         Build shared library (.so)
 * -fvisibility=hidden  Hide internal symbols
 *
 * == DEFINITIONS ==
 * -DNAME          Define NAME as 1
 * -DNAME=value    Define NAME with value
 * -UNAME          Undefine NAME
 *
 * == INCLUDES ==
 * -Idir           Add directory to include search path
 * -isystem dir    System include directory
 *
 * == LINKER FLAGS ==
 * -Ldir           Add directory to library search path
 * -lname          Link with library libname.so/.a
 * -Wl,flag        Pass 'flag' directly to linker
 * -Wl,-rpath,dir  Set runtime library search path
 * -static         Static linking (no shared libs)
 *
 */

#ifndef TWO_AM_BUILDER_H
#define TWO_AM_BUILDER_H

/*
 * 2AM Build System Public API
 *
 * For single-header usage: #define TWO_AM_BUILD_IMPL before including
 */

#ifndef _POSIX_C_SOURCE
#    define _POSIX_C_SOURCE 200809L
#endif

#include <stdbool.h> // bool

/**
 * @brief Type of build output.
 */
typedef enum {
    BUILD_EXE,    /**< Executable binary */
    BUILD_SHARED, /**< Shared library (.so) */
    BUILD_STATIC  /**< Static library (.a) */
} build_type_t;

/**
 * @brief Type of object layout output for compiled files.
 *
 * By default, mirrors your source directory structure (AM_MIRROR).
 * For small experiments or learning projects, you can switch to a flat layout.
 */
typedef enum {
    AM_MIRROR, /** Mirror source directory structure */
    AM_FLAT,   /** Flat layout: all objects in one directory */
} object_layout_t;

/**
 * @brief Initialize the build system.
 *
 * Call this once before doing anything else.
 * Allocates internal state and prepares the build environment.
 *
 * If you forget this, everything else is undefined behavior.
 */
void AM_INIT(void);

/**
 * @brief Reset all target-specific build state.
 *
 * Call this after finishing a build before defining the next target.
 * Clears sources, flags, includes, libraries, and questionable decisions.
 *
 * Skipping this step may result in creative but incorrect builds.
 */
void AM_RESET(void);

/**
 * @brief Set the compiler and language standard.
 *
 * @param compiler  Compiler executable name (e.g. "clang", "gcc")
 * @param c_version Language standard (e.g. "c99", "c11", "gnu++20")
 */
void AM_SET_COMPILER(const char *compiler, const char *c_version);

/**
 * @brief Set compiler warning flags.
 *
 * Flags must be provided as a comma-separated string.
 *
 * Example:
 * @code
 * AM_SET_COMPILER_WARN("-g, -Wall, -Wextra");
 * @endcode
 *
 * @param warning Compiler warning flags.
 */
void AM_SET_COMPILER_WARN(const char *warning);

/**
 * @brief Set output directories for build artifacts.
 *
 * @param binary_path Directory for final binaries and libraries.
 * @param object_path Directory for intermediate object files.
 */
void AM_SET_TARGET_DIRS(const char *binary_path, const char *object_path);

/**
 * @brief Set the name of the build target.
 *
 * Determines the output file name.
 * Choose something reasonable. Or funny. Your call.
 *
 * @param target_name Target name.
 */
void AM_SET_TARGET_NAME(const char *target_name);

/**
 * @brief Add compiler flags.
 *
 * Flags must be provided as a comma-separated string.
 *
 * Example:
 * @code
 * AM_SET_FLAGS("-fPIC, -DDEBUG");
 * @endcode
 *
 * @param flags Compiler flags.
 */
void AM_SET_FLAGS(const char *flags);

/**
 * @brief Add an include directory to the compiler search path.
 *
 * @param include_dir Path to the include directory.
 */
void AM_ADD_INCLUDE(const char *include_dir);

/**
 * @brief Add all source files from a directory recursively.
 *
 * @param path Directory containing source files.
 */
void AM_SET_SOURCE_ALL(const char *path);

/**
 * @brief Add specific source files from a directory.
 *
 * @param path  Base directory of the source files.
 * @param files NULL-terminated list of source filenames.
 */
void AM_SET_SOURCE_SPECIFIC(const char *path, const char **files);

/**
 * @brief Add source files from a directory while excluding a subdirectory.
 *
 * Perfect for skipping vendor code, generated files,
 * or that one folder you refuse to look at.
 *
 * @param base_path     Base source directory.
 * @param exclude_path Subdirectory to exclude.
 */
void AM_SET_SOURCE_WITH_EXCLUDE(const char *base_path,
                                const char *exclude_path);

/**
 * @brief Link against a prebuilt library.
 *
 * The library must already exist on disk.
 * If it doesn’t, the linker will remind you.
 *
 * @param lib_name Name of the library without the "lib" prefix.
 * @param lib_path Directory containing the library.
 */
void AM_USE_PREBUILT_LIB(const char *lib_name, const char *lib_path);

/**
 * @brief Link against system or external libraries.
 *
 * Libraries must be provided as a comma-separated string without the
 * "lib" prefix.
 *
 * Example:
 * @code
 * AM_USE_LIB("GL, m, dl, rt, X11");
 * @endcode
 *
 * @param lib_name Comma-separated list of library names.
 */
void AM_USE_LIB(const char *lib_name);

/**
 * @brief Add linker-specific flags.
 *
 * Flags must be provided as a comma-separated string.
 *
 * Example:
 * @code
 * AM_ADD_LINKER_FLAGS("-Wl,-rpath,.");
 * @endcode
 *
 * @param linker_flags Linker flags.
 */
void AM_ADD_LINKER_FLAGS(const char *linker_flags);

/**
 * @brief Build the configured target.
 *
 * This is where everything comes together: compilation, linking, and mild
 * anxiety.
 *
 * @param type            Type of output to build.
 * @param use_dependency  Enable dependency tracking and incremental builds.
 */
void AM_BUILD(build_type_t type, bool use_dependency);

/**
 * @brief Generate compilation database.
 *
 * Provided database for your project with '.json' format, which clangd happy
 * about it.
 *
 */
void AM_GEN_DATABASE(void);

/**
 * @brief Deploy prebuilt library to system-wide installation.
 *
 * Install an already-built shared library into the system library path
 * and optionally install its public headers so the library can be used
 * like a standard system dependency (e.g. GLFW, SDL).
 *
 * Notes:
 * - Requires superuser privileges (run the executable with sudo),
 * - The shared library must already exist
 * - Header installation supports:
 *     - A directory (recursive copy of *.h)
 *     - A single header file
 * - The 'lib' prefix is stripped from the include directory name:
 *     libtwoam.so -> /usr/include/twoam/
 *
 * @param system_mode 	Enable install library and public header to system
 * @param library_path  Relative path to the shared library WITHOUT ".so"
 * @param header_path   Path to public header file or directory (optional)
 * @param has_headers   Enable public header installation
 */
void AM_PREBUILT_TO_SYSTEM(bool system_mode, const char *library_path,
                           const char *header_path, bool has_headers);

/**
 * @brief Set the object layout for subsequent builds.
 *
 * Should be called before AM_BUILD. If not called, default is AM_MIRROR.
 */
void AM_SET_OBJECT_LAYOUT(object_layout_t);

#ifdef TWO_AM_BUILD_IMPL

#    if defined(__APPLE__)
#        define PLATFORM_MACOS 1
#        define SHARED_EXT ".dylib"
#        define DEFAULT_SYSTEM_LIB "/usr/local/lib"
#        define DEFAULT_SYSTEM_INC "/usr/local/include"

#    elif defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__NetBSD__)
#        define PLATFORM_BSD 1
#        define SHARED_EXT ".so"
#        define DEFAULT_SYSTEM_LIB "/usr/local/lib"
#        define DEFAULT_SYSTEM_INC "/usr/local/include"

#    elif defined(__linux__)
#        define PLATFORM_LINUX 1
#        define SHARED_EXT ".so"
#        define DEFAULT_SYSTEM_LIB "/usr/lib"
#        define DEFAULT_SYSTEM_INC "/usr/include"

// NOTE: this just boilerplate to make it pretty. hahahah
#    elif defined(_WIN32) || defined(_WIN64)
#        define PLATFORM_WINDOWS 1
#        define SHARED_EXT ".dll"
#        define DEFAULT_SYSTEM_LIB "C:\\Windows\\System32"
#        define DEFAULT_SYSTEM_INC "C:\\Program Files\\Include"

#    else
#        define PLATFORM_UNKNOWN 1
#        define SHARED_EXT ".so" // Conservative default
#        define DEFAULT_SYSTEM_LIB "/usr/lib"
#        define DEFAULT_SYSTEM_INC "/usr/include"
#    endif

#    include <dirent.h>   // dirent struct, opendir, closedir
#    include <stdio.h>    // printf, snprintf, strtok, strdup
#    include <stdlib.h>   // calloc
#    include <string.h>   // strncpy, strrchr
#    include <sys/stat.h> // mkdir, stat struct, S_ISDIR, S_ISREG
#    include <sys/wait.h> // waitpid
#    include <unistd.h>   // pid struct, execvp, _exit
#    include <fcntl.h>    // open

#    define MAX_LIB 16
#    define MAX_LIB_PATH 16
#    define MAX_INC 16
#    define MAX_LINKER_FLAG 16

#    define MAX_WARN 64
#    define MAX_FLAG 64
#    define MAX_ARGS 64

#    define MAX_SRC 256
#    define MAX_PATH 256

typedef struct {
    char compiler[32];
    char std_flag[32];

    char warn_list[MAX_WARN][64];
    int warn_count;

    char flag_list[MAX_FLAG][64];
    int flag_count;

    char linker_list[MAX_LINKER_FLAG][64];
    int linker_count;
} compiler_config_t;

typedef struct {
    char bin[128];
    char build[128];
} build_dir_t;

typedef struct {
    char src_dir[128];
    char *src_list[MAX_SRC];
    char src_path[MAX_SRC][MAX_PATH];
    int src_count;

    char exclude_path[MAX_PATH];

    bool generate_deps;
} source_file_t;

typedef struct {
    char include_dirs[MAX_INC][MAX_PATH];
    int include_count;
} include_config_t;

typedef struct {
    char libs[MAX_LIB][64];
    int lib_count;

    char custom_lib_path[MAX_LIB_PATH][MAX_PATH];
    char custom_lib_name[MAX_LIB_PATH][32];
    int custom_lib_path_count;
} library_config_t;

typedef struct {
    char *args[MAX_ARGS];
    int argc;
    char *file;
    char *output;
} compdb_entry_t;

typedef struct {
    compiler_config_t comp_cfg;
    build_dir_t target_dirs;
    source_file_t target_srcs;
    include_config_t includes;
    library_config_t libs;

    compdb_entry_t compdb[512];
    int compdb_count;
    bool export_compdb;
    bool compdb_written;

    build_type_t build_type;
    char target_name[64];
    bool initialized;
    bool is_mirrored;
} am_state_t;

static am_state_t *g_am = {0};
static const char *g_pkg_lib_dir = {0};
static const char *g_pkg_inc_dir = {0};

// clang-format off
static const char *multiarch_dirs[] = {
    "/usr/lib/x86_64-linux-gnu",
	"/usr/lib/aarch64-linux-gnu",
    "/usr/lib/arm-linux-gnueabihf",
	"/usr/lib/powerpc64le-linux-gnu",
    "/usr/lib/mips64el-linux-gnuabi64",
	NULL};
// clang-format on

static int mkdir_if_not_exists(const char *path)
{
    struct stat st = {0};
    if (stat(path, &st) == -1) return mkdir(path, 0777);
    return 0;
}

static void mkdir_recursive(const char *path)
{
    char tmp[MAX_PATH];
    strncpy(tmp, path, sizeof(tmp));
    tmp[sizeof(tmp) - 1] = 0;

    for (char *p = tmp + 1; *p; ++p)
    {
        if (*p == '/')
        {
            *p = 0;
            mkdir_if_not_exists(tmp);
            *p = '/';
        }
    }
    mkdir_if_not_exists(path);
}

static const char *pkg_lib_name(const char *library_path)
{
    const char *slash = strrchr(library_path, '/');
    return slash ? slash + 1 : library_path;
}

static int copy_file(const char *src, const char *dst)
{
    int in = open(src, O_RDONLY);
    if (in < 0) return -1;

    // 06444 = Readable by all, only owner can modify
    int out = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (out < 0)
    {
        close(in);
        return -1;
    }

    char buf[4096];
    ssize_t n;
    while ((n = read(in, buf, sizeof(buf))) > 0)
        if (write(out, buf, (size_t)n) != n)
        {
            close(in);
            close(out);
            return -1;
        }

    close(in);
    close(out);
    return (n < 0) ? -1 : 0;
}

static inline void copy_headers(const char *src_dir, const char *dst_dir)
{
    mkdir_recursive(dst_dir);

    DIR *dir = opendir(src_dir);
    if (!dir) return;

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL)
    {
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, ".."))
            continue;

        char src_path[MAX_PATH], dst_path[MAX_PATH];
        snprintf(src_path, sizeof(src_path), "%s/%s", src_dir, entry->d_name);
        snprintf(dst_path, sizeof(dst_path), "%s/%s", dst_dir, entry->d_name);

        struct stat st;
        if (stat(src_path, &st) != 0) continue;

        if (S_ISDIR(st.st_mode))
        {
            copy_headers(src_path, dst_path);
        }
        else if (S_ISREG(st.st_mode))
        {
            const char *ext = strrchr(entry->d_name, '.');
            if (ext && strcmp(ext, ".h") == 0)
            {
                copy_file(src_path, dst_path);
            }
        }
    }

    closedir(dir);
}

static int install_shared_library(const char *library_path,
                                  const char *lib_name)
{
    char src[MAX_PATH];
    char dst[MAX_PATH];

    snprintf(src, sizeof(src), "%s.so", library_path);

    // check if file was actually .so file
    struct stat st;
    if (stat(src, &st) != 0 || !S_ISREG(st.st_mode))
    {
        fprintf(stderr, "invalid shared library '%s'\n", src);
        return -1;
    }

    snprintf(dst, sizeof(dst), "%s/%s.so", g_pkg_lib_dir, lib_name);

    return copy_file(src, dst);
}

static int install_headers(const char *header_path, const char *lib_name)
{
    struct stat st;
    if (stat(header_path, &st) != 0) return -1;

    const char *inc_name =
        (strncmp(lib_name, "lib", 3) == 0) ? lib_name + 3 : lib_name;

    char dst_dir[MAX_PATH];
    snprintf(dst_dir, sizeof(dst_dir), "%s/%s", g_pkg_inc_dir, inc_name);
    mkdir_recursive(dst_dir);

    if (S_ISDIR(st.st_mode))
    {
        copy_headers(header_path, dst_dir);
        return 0;
    }

    if (S_ISREG(st.st_mode))
    {
        const char *slash = strrchr(header_path, '/');
        const char *hdr = slash ? slash + 1 : header_path;

        char dst[MAX_PATH];
        snprintf(dst, sizeof(dst), "%s/%s", dst_dir, hdr);
        return copy_file(header_path, dst);
    }

    return -1;
}

static int setup_install_paths(bool system_mode)
{
    if (system_mode)
    {
        if (geteuid() != 0)
        {
            fprintf(stderr, "AM_PREBUILT_TO_SYSTEM: system install requires "
                            "root privileges.\n"
                            "Hint: run with sudo.\n");
            return -1;
        }

#    if PLATFORM_LINUX
        struct stat st;
        const char *lib_dir = "/usr/lib";

        // check for multiarch directories (Debian/Ubuntu)
        for (int i = 0; multiarch_dirs[i]; ++i)
        {
            if (stat(multiarch_dirs[i], &st) == 0 && S_ISDIR(st.st_mode))
            {
                lib_dir = multiarch_dirs[i];
                break;
            }
        }

        // if no multiarch, check for lib64 (RHEL/Fedora/CentOS)
        if (strcmp(lib_dir, "/usr/lib") == 0 && stat("/usr/lib64", &st) == 0 &&
            S_ISDIR(st.st_mode))
        {
            lib_dir = "/usr/lib64";
        }

        // fallback to default (Arch)
        g_pkg_lib_dir = lib_dir;
        g_pkg_inc_dir = DEFAULT_SYSTEM_INC;

#    elif PLATFORM_MACOS || PLATFORM_BSD
        g_pkg_lib_dir = DEFAULT_SYSTEM_LIB;
        g_pkg_inc_dir = DEFAULT_SYSTEM_INC;
#    else
        fprintf(stderr, "Unsupported platform for system install\n");
        return -1;
#    endif
    }
    else
    {
        g_pkg_lib_dir = "./_pkg_test/lib";
        g_pkg_inc_dir = "./_pkg_test/include";

        mkdir_recursive(g_pkg_lib_dir);
        mkdir_recursive(g_pkg_inc_dir);
    }

    return 0;
}

static bool is_c_source(const char *filename)
{
    if (!filename) return false;

    const char *ext = strrchr(filename, '.');
    if (!ext) return false;

    return (strcmp(ext, ".c") == 0) || (strcmp(ext, ".C") == 0) ||
           (strcmp(ext, ".cc") == 0) || (strcmp(ext, ".cpp") == 0) ||
           (strcmp(ext, ".cxx") == 0) || (strcmp(ext, ".c++") == 0);
}

static bool match_pattern(const char *filename, const char *pattern)
{
    // simple wildcard
    if (!filename || !pattern) return false;

    const char *f = filename;
    const char *p = pattern;
    const char *star = NULL;
    const char *fpos = NULL;

    while (*f)
    {
        if (*p == '*')
        {
            star = p++;
            fpos = f;
            continue;
        }
        if (*p == *f || *p == '?')
        {
            p++;
            f++;
            continue;
        }
        if (star)
        {
            p = star + 1;
            f = ++fpos;
            continue;
        }
        return false;
    }
    while (*p == '*') p++;
    return *p == '\0';
}

static bool should_exclude_path(const char *full_path, const char *exclude)
{
    if (!full_path || !exclude || exclude[0] == '\0') return false;

    const char *rel_path = full_path;
    if (strncmp(full_path, g_am->target_srcs.src_dir,
                strlen(g_am->target_srcs.src_dir)) == 0)
    {
        rel_path = full_path + strlen(g_am->target_srcs.src_dir);
        if (*rel_path == '/') rel_path++;
    }

    // check the relative path against patterns
    char patterns[MAX_PATH];
    strncpy(patterns, exclude, sizeof(patterns) - 1);
    patterns[sizeof(patterns) - 1] = '\0';

    char *pattern = strtok(patterns, ",");
    while (pattern)
    {
        while (*pattern == ' ') pattern++;
        char *end = pattern + strlen(pattern) - 1;
        while (end > pattern && *end == ' ')
        {
            *end = '\0';
            end--;
        }

        // Check if pattern matches the relative path
        if (match_pattern(rel_path, pattern) ||
            strstr(rel_path, pattern) != NULL)
        {
            return true;
        }

        pattern = strtok(NULL, ",");
    }

    return false;
}

static int run_process(char *const argv[])
{
    // https://unix.stackexchange.com/questions/136637/why-do-we-need-to-fork-to-create-new-processes/136649#136649

    // Create a new process (fork)
    // this means, the build .c file was the parent and child was other program
    // that we called, on this case was the compiler
    pid_t pid = fork();

    if (pid == 0)
    {
        // Child: replace itself with the compiler program
        execvp(argv[0], argv);
        perror("execvp failed");
        _exit(1);
    }
    else if (pid > 0)
    {
        // Parent: wait for the compiler to finish
        int status = 0;
        waitpid(pid, &status, 0);
        return status;
    }
    else
    {
        perror("fork failed");
        return -1;
    }
}

static int needs_recompile(const char *source_path, const char *object_path)
{
    struct stat src_stat, obj_stat;

    if (stat(source_path, &src_stat) != 0) return 1;
    if (stat(object_path, &obj_stat) != 0) return 1;
    if (src_stat.st_mtime > obj_stat.st_mtime) return 1;

    if (g_am->target_srcs.generate_deps)
    {
        char dep_path[MAX_PATH];
        strncpy(dep_path, object_path, MAX_PATH - 1);
        char *dot = strrchr(dep_path, '.');
        if (dot)
            strcpy(dot, ".d");
        else
            strcat(dep_path, ".d");

        struct stat dep_stat;
        if (stat(dep_path, &dep_stat) != 0) return 1;

        FILE *dep_file = fopen(dep_path, "r");
        if (dep_file)
        {
            char line[1024];
            while (fgets(line, sizeof(line), dep_file))
            {
                char *token = strtok(line, " \t\n:\\");
                while (token)
                {
                    // Skip the object file itself (first token)
                    if (strcmp(token, object_path) != 0 &&
                        strcmp(token, source_path) != 0)
                    {
                        struct stat hdr_stat;
                        if (stat(token, &hdr_stat) == 0)
                        {
                            if (hdr_stat.st_mtime > obj_stat.st_mtime)
                            {
                                fclose(dep_file);
                                return 1;
                            }
                        }
                    }
                    token = strtok(NULL, " \t\n:\\");
                }
            }
            fclose(dep_file);
        }
    }

    return 0;
}

static int compile_source_with_deps(const char *source_path,
                                    const char *object_path)
{
    char *argv[256] = {0};
    int argc = 0;

    argv[argc++] = g_am->comp_cfg.compiler;
    argv[argc++] = g_am->comp_cfg.std_flag;

    for (int i = 0; i < g_am->includes.include_count; ++i)
    {
        // argv[argc++] = "-I";
        argv[argc++] = g_am->includes.include_dirs[i];
    }

    for (int i = 0; i < g_am->comp_cfg.warn_count; ++i)
    {
        argv[argc++] = g_am->comp_cfg.warn_list[i];
    }

    for (int i = 0; i < g_am->comp_cfg.flag_count; ++i)
    {
        argv[argc++] = g_am->comp_cfg.flag_list[i];
    }

    // Generate dependency file (.d extension)
    if (g_am->target_srcs.generate_deps)
    {
        char dep_path[MAX_PATH];
        strncpy(dep_path, object_path, MAX_PATH - 1);
        char *dot = strrchr(dep_path, '.');
        if (dot)
            strcpy(dot, ".d");
        else
            strcat(dep_path, ".d");

        argv[argc++] = "-MMD"; // Generate dependencies, ignore system headers
        argv[argc++] = "-MP";  // Add phony targets for each dependency
        argv[argc++] = "-MF";  // Output dependency file
        argv[argc++] = dep_path; // Dependency file path
    }

    argv[argc++] = "-o";
    argv[argc++] = (char *)object_path;
    argv[argc++] = (char *)source_path;
    argv[argc++] = "-c";
    argv[argc] = NULL;

    return run_process(argv);
}

static int link_objects(const char **object_files, int count,
                        const char *output_path)
{
    char *argv[256] = {0};
    int argc = 0;

    argv[argc++] = g_am->comp_cfg.compiler; // compiler
    for (int i = 0; i < count; ++i) argv[argc++] = (char *)object_files[i];

    argv[argc++] = "-o";
    argv[argc++] = (char *)output_path; // output option

    // Library flags based on build type
    if (g_am->build_type == BUILD_SHARED)
    {
        argv[argc++] = "-shared";
    }

    // Add linker flags
    for (int i = 0; i < g_am->comp_cfg.linker_count; ++i)
    {
        argv[argc++] = g_am->comp_cfg.linker_list[i];
    }

    // Add custom library search paths (-L) and libraries (-l)
    for (int i = 0; i < g_am->libs.custom_lib_path_count; ++i)
    {
        argv[argc++] = "-L";
        argv[argc++] = g_am->libs.custom_lib_path[i];

        argv[argc++] = "-l";
        argv[argc++] = g_am->libs.custom_lib_name[i];
    }

    // Add system libraries (-l)
    for (int i = 0; i < g_am->libs.lib_count; ++i)
    {
        argv[argc++] = "-l";
        argv[argc++] = g_am->libs.libs[i];
    }

    argv[argc] = NULL;

    return run_process(argv);
}

static int create_static_lib(const char **object_files, int count,
                             const char *output_path)
{
    char *argv[128] = {0};
    int argc = 0;

    argv[argc++] = "ar";
    argv[argc++] = "rcs";
    argv[argc++] = (char *)output_path;

    for (int i = 0; i < count; i++) argv[argc++] = (char *)object_files[i];
    argv[argc] = NULL;

    return run_process(argv);
}

static inline void string_delimiter(const char *input, char delim,
                                    char out[][64], int *count, int max_item)
{
    *count = 0;
    char buf[MAX_PATH];
    strncpy(buf, input, sizeof(buf) - 1);
    buf[sizeof(buf) - 1] = '\0';

    char delim_str[2] = {delim, '\0'};
    char *tok = strtok(buf, delim_str);

    while (tok && *count < max_item)
    {
        while (*tok == ' ') tok++; // trim leading spaces

        if (*tok == '\0')
        {
            tok = strtok(NULL, delim_str);
            continue;
        }

        char *end = tok + strlen(tok) - 1; // trim trailing spaces
        while (end > tok && *end == ' ')
        {
            *end = '\0';
            end--;
        }

        strncpy(out[*count], tok, 31);
        out[*count][31] = '\0';
        (*count)++;
        tok = strtok(NULL, delim_str);
    }
}

static void set_source_internal(const char *path)
{
    if (!path || strcmp(path, ".") == 0 || strcmp(path, "./") == 0)
    {
        fprintf(stderr,
                "Error: AM_SET_SOURCE_*(\"%s\") is not allowed.\n"
                "Source files must live in a directory (e.g. src/).\n",
                path ? path : "(null)");
        exit(1);
    }

    strncpy(g_am->target_srcs.src_dir, path,
            sizeof(g_am->target_srcs.src_dir) - 1);
    g_am->target_srcs.src_dir[sizeof(g_am->target_srcs.src_dir) - 1] = '\0';

    for (int i = 0; i < g_am->target_srcs.src_count; ++i)
    {
        free(g_am->target_srcs.src_list[i]);
    }

    g_am->target_srcs.src_count = 0;
}

static inline void scan_dir_recursive(const char *dir_path,
                                      const char *exclude)
{
    DIR *dir = opendir(dir_path);
    if (!dir) return;

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL)
    {
        if (strcmp(entry->d_name, ".") == 0 ||
            strcmp(entry->d_name, "..") == 0)
            continue;

        // Build full path
        char full_path[MAX_PATH];
        snprintf(full_path, sizeof(full_path), "%s/%s", dir_path,
                 entry->d_name);

        // Check if directory
        struct stat st;
        if (stat(full_path, &st) == 0 && S_ISDIR(st.st_mode))
        {
            if (!should_exclude_path(full_path, exclude))
            {
                scan_dir_recursive(full_path, exclude);
            }
            continue;
        }

        if (!is_c_source(entry->d_name)) continue;
        if (should_exclude_path(entry->d_name, exclude)) continue;

        if (g_am->target_srcs.src_count < MAX_SRC)
        {
            const char *rel_path =
                full_path + strlen(g_am->target_srcs.src_dir);
            if (*rel_path == '/') rel_path++;

            g_am->target_srcs.src_list[g_am->target_srcs.src_count] =
                strdup(rel_path);
            strncpy(g_am->target_srcs.src_path[g_am->target_srcs.src_count],
                    full_path, MAX_PATH - 1);
            g_am->target_srcs
                .src_path[g_am->target_srcs.src_count][MAX_PATH - 1] = '\0';
            g_am->target_srcs.src_count++;
        }
    }

    closedir(dir);
}

static char *gen_object_path(const char *source_path, char *obj_buffer)
{
    const char *rel = source_path;

    if (g_am->is_mirrored)
    {
        const char *root = g_am->target_srcs.src_dir;
        size_t root_len = strlen(root);

        if (strncmp(source_path, root, root_len) == 0)
        {
            rel = source_path + root_len;
            if (*rel == '/') rel++;
        }
    }
    else
    {
        const char *base = strrchr(source_path, '/');
        if (base) rel = base + 1;
    }

    strncpy(obj_buffer, rel, MAX_PATH - 1);
    char *dot = strrchr(obj_buffer, '.');
    if (dot)
        strcpy(dot, ".o");
    else
        strcat(obj_buffer, ".o");

    return obj_buffer;
}

static int build_compdb(void)
{
    if (!g_am->export_compdb || g_am->compdb_count == 0) return 0;

    FILE *f = fopen("compile_commands.json", "w");
    if (!f)
    {
        perror("compile_commands.json");
        return 0;
    }

    static char cwd[MAX_PATH];
    if (cwd[0] == '\0')
    {
        if (!getcwd(cwd, sizeof(cwd))) strcpy(cwd, ".");
    }

    fprintf(f, "[\n");
    for (int i = 0; i < g_am->compdb_count; ++i)
    {
        compdb_entry_t *e = &g_am->compdb[i];

        fprintf(f,
                "  {\n"
                "    \"directory\": \"%s\",\n"
                "    \"arguments\": [\n",
                cwd);

        for (int j = 0; j < e->argc; ++j)
        {
            fprintf(f, "      \"%s\"%s\n", e->args[j],
                    (j + 1 < e->argc) ? "," : "");
        }

        fprintf(f,
                "    ],\n"
                "    \"file\": \"%s\"",
                e->file);

        if (e->output)
        {
            fprintf(f,
                    ",\n"
                    "    \"output\": \"%s\"",
                    e->output);
        }

        fprintf(f,
                "\n"
                "  }%s\n",
                (i + 1 < g_am->compdb_count) ? "," : "");
    }

    fprintf(f, "]\n");
    fclose(f);

    printf("Generated: compile_commands.json (%d entries)\n",
           g_am->compdb_count);

    g_am->compdb_written = true;
    return 1;
}

static int build_compile_cmd(char **argv, const char *src, const char *obj)
{
    int argc = 0;

    argv[argc++] = g_am->comp_cfg.compiler;
    argv[argc++] = g_am->comp_cfg.std_flag;

    // warnings
    for (int i = 0; i < g_am->comp_cfg.warn_count; ++i)
        argv[argc++] = g_am->comp_cfg.warn_list[i];

    // extra flags (-fPIC, etc)
    for (int i = 0; i < g_am->comp_cfg.flag_count; ++i)
        argv[argc++] = g_am->comp_cfg.flag_list[i];

    // includes
    for (int i = 0; i < g_am->includes.include_count; ++i)
        argv[argc++] = g_am->includes.include_dirs[i];

    argv[argc++] = "-c";
    argv[argc++] = (char *)src;
    argv[argc++] = "-o";
    argv[argc++] = (char *)obj;
    argv[argc] = NULL;

    return argc;
}

static int compile_sources(const char **object_files, int *obj_count)
{
    *obj_count = 0;
    for (int i = 0; i < g_am->target_srcs.src_count; ++i)
    {
        char obj_name[MAX_PATH];
        char obj_path[MAX_PATH];
        char obj_dir[MAX_PATH];
        char *argv[MAX_ARGS];

        const char *src = g_am->target_srcs.src_path[i];

        gen_object_path(src, obj_name);
        snprintf(obj_path, sizeof(obj_path), "%s/%s", g_am->target_dirs.build,
                 obj_name);

        strncpy(obj_dir, obj_path, MAX_PATH - 1);
        obj_dir[MAX_PATH - 1] = '\0';

        char *slash = strrchr(obj_dir, '/');
        if (slash)
        {
            *slash = '\0';
            mkdir_recursive(obj_dir);
            // *slash = '/';
        }

        // compilation database
        int argc = build_compile_cmd(argv, src, obj_path);
        if (g_am->compdb_count < MAX_SRC)
        {
            compdb_entry_t *e = &g_am->compdb[g_am->compdb_count++];
            e->argc = argc;

            for (int j = 0; j < argc; ++j) e->args[j] = strdup(argv[j]);

            e->file = strdup(src);
            e->output = strdup(obj_path);
        }

        // dependency re-compile
        if (needs_recompile(src, obj_path) == 0)
        {
            printf("Up-to-date: %s\n", src);
            object_files[*obj_count] = strdup(obj_path);
            (*obj_count)++;
            continue;
        }

        printf("Compiling: %s...\n", src);

        // actual compile
        if (compile_source_with_deps(src, obj_path) != 0)
        {
            fprintf(stderr, "Compilation failed for: %s\n", src);
            return 0;
        }

        object_files[*obj_count] = strdup(obj_path);
        (*obj_count)++;
    }

    return 1;
}

static void get_output_ext(build_type_t type, const char **prefix,
                           const char **ext)
{
    switch (type)
    {
    case BUILD_EXE:
        *prefix = "";
        *ext = "";
        break;
    case BUILD_SHARED:
        *prefix = "lib";
        *ext = SHARED_EXT;
        break;
    case BUILD_STATIC:
        *prefix = "lib";
        *ext = ".a";
        break;
    }
}

static void build_output(const char *output_path, build_type_t type,
                         const char **object_files, int obj_count)
{
    if (type == BUILD_STATIC)
    {
        create_static_lib(object_files, obj_count, output_path);
    }
    else
    {
        link_objects(object_files, obj_count, output_path);
    }
}

static void print_sum(const char *output_path, build_type_t type)
{
    const char *type_str = type == BUILD_EXE      ? "executable"
                           : type == BUILD_SHARED ? "shared library"
                                                  : "static library";

    printf("Building target: %s\n", g_am->target_name);
    printf("Build type: %s\n", type_str);
    printf("Output: %s\n", output_path);
    printf("Sources: %d\n", g_am->target_srcs.src_count);
}

static inline int validate_build(void)
{
    if (!g_am)
    {
        printf("Error: Builder not initialized\n");
        return 0;
    }
    if (g_am->comp_cfg.compiler[0] == '\0')
    {
        printf("Error: No compiler specified\n");
        return 0;
    }
    if (g_am->target_name[0] == '\0')
    {
        printf("Error: No target name specified\n");
        return 0;
    }
    if (g_am->target_srcs.src_count == 0)
    {
        printf("Error: No source files added\n");
        return 0;
    }
    if (g_am->target_dirs.bin[0] == '\0' || g_am->target_dirs.build[0] == '\0')
    {
        printf("Error: No binary & object path specified\n");
        return 0;
    }

    return 1;
}

void AM_INIT(void)
{
    if (!g_am)
    {
        g_am = calloc(1, sizeof(am_state_t));
        if (!g_am)
        {
            fprintf(stderr, "Failed to allocate builder state\n");
            exit(1);
        }
    }
    g_am->initialized = true;
    g_am->compdb_written = false;
    g_am->is_mirrored = true;
}

void AM_RESET(void)
{
    if (!g_am) return;

    // clear target sources count allocation
    for (int i = 0; i < g_am->target_srcs.src_count; ++i)
    {
        free(g_am->target_srcs.src_list[i]);
        g_am->target_srcs.src_list[i] = NULL;
    }

    for (int i = 0; i < g_am->compdb_count; ++i)
    {
        compdb_entry_t *e = &g_am->compdb[i];

        for (int j = 0; j < e->argc; ++j)
        {
            free(e->args[j]);
            e->args[j] = NULL;
        }

        free(e->file);
        free(e->output);

        e->file = NULL;
        e->output = NULL;
        e->argc = 0;
    }

    g_am->compdb_count = 0;
    g_am->export_compdb = false;
    g_am->compdb_written = false;

    memset(g_am, 0, sizeof(am_state_t));

    g_am->target_srcs.generate_deps = true;
    g_am->build_type = BUILD_EXE;
}

void AM_SET_COMPILER(const char *compiler, const char *c_version)
{
    strncpy(g_am->comp_cfg.compiler, compiler,
            sizeof(g_am->comp_cfg.compiler) - 1);

    snprintf(g_am->comp_cfg.std_flag, sizeof(g_am->comp_cfg.std_flag),
             "-std=%s", c_version);
}

void AM_SET_COMPILER_WARN(const char *warning)
{
    string_delimiter(warning, ',', g_am->comp_cfg.warn_list,
                     &g_am->comp_cfg.warn_count, MAX_WARN);
}

void AM_SET_TARGET_DIRS(const char *binary_path, const char *object_path)
{
    strncpy(g_am->target_dirs.bin, binary_path,
            sizeof(g_am->target_dirs.bin) - 1);
    mkdir_if_not_exists(binary_path);

    strncpy(g_am->target_dirs.build, object_path,
            sizeof(g_am->target_dirs.build) - 1);
    mkdir_if_not_exists(object_path);
}

void AM_SET_FLAGS(const char *flags)
{
    string_delimiter(flags, ',', g_am->comp_cfg.flag_list,
                     &g_am->comp_cfg.flag_count, MAX_FLAG);
}

void AM_ADD_INCLUDE(const char *include_dir)
{
    if (!g_am || !include_dir || g_am->includes.include_count >= MAX_INC)
        return;

    strncpy(g_am->includes.include_dirs[g_am->includes.include_count],
            include_dir, MAX_PATH - 1);

    snprintf(g_am->includes.include_dirs[g_am->includes.include_count],
             MAX_PATH, "-I%s", include_dir);

    g_am->includes.include_count++;
}

void AM_SET_SOURCE_ALL(const char *path)
{
    if (!path) return;
    set_source_internal(path);

    g_am->target_srcs.exclude_path[0] = '\0';
    g_am->target_srcs.generate_deps = true;
}

void AM_SET_SOURCE_SPECIFIC(const char *path, const char **files)
{
    if (!path || !files) return;
    set_source_internal(path);
    g_am->target_srcs.exclude_path[0] = '\0';

    g_am->target_srcs.src_count = 0;
    for (int i = 0; files[i] && i < MAX_SRC; ++i)
    {
        g_am->target_srcs.src_list[i] = strdup(files[i]);
        snprintf(g_am->target_srcs.src_path[i], MAX_PATH, "%s/%s", path,
                 files[i]);
        g_am->target_srcs.src_count++;
    }
}

void AM_SET_SOURCE_WITH_EXCLUDE(const char *base_path,
                                const char *exclude_path)
{
    if (!base_path) return;
    set_source_internal(base_path);

    if (exclude_path)
    {
        strncpy(g_am->target_srcs.exclude_path, exclude_path,
                sizeof(g_am->target_srcs.exclude_path) - 1);
        g_am->target_srcs
            .exclude_path[sizeof(g_am->target_srcs.exclude_path) - 1] = '\0';
    }
    else
    {
        g_am->target_srcs.exclude_path[0] = '\0';
    }
}

void AM_USE_PREBUILT_LIB(const char *lib_name, const char *lib_path)
{
    if (!g_am || !lib_name || !lib_path ||
        g_am->libs.custom_lib_path_count >= MAX_LIB_PATH)
        return;

    int count = g_am->libs.custom_lib_path_count;

    strncpy(g_am->libs.custom_lib_name[count], lib_name,
            sizeof(g_am->libs.custom_lib_name[0]) - 1);
    g_am->libs
        .custom_lib_name[count][sizeof(g_am->libs.custom_lib_name[0]) - 1] =
        '\0';

    strncpy(g_am->libs.custom_lib_path[count], lib_path,
            sizeof(g_am->libs.custom_lib_path[0]) - 1);
    g_am->libs
        .custom_lib_path[count][sizeof(g_am->libs.custom_lib_path[0]) - 1] =
        '\0';

    g_am->libs.custom_lib_path_count++;
}

void AM_USE_LIB(const char *lib_name)
{
    string_delimiter(lib_name, ',', g_am->libs.libs, &g_am->libs.lib_count,
                     MAX_LIB);
}

void AM_ADD_LINKER_FLAGS(const char *linker_flags)
{
    string_delimiter(linker_flags, ',', g_am->comp_cfg.linker_list,
                     &g_am->comp_cfg.linker_count, MAX_LINKER_FLAG);
}

void AM_SET_TARGET_NAME(const char *target_name)
{
    strncpy(g_am->target_name, target_name, sizeof(g_am->target_name) - 1);
    g_am->target_name[sizeof(g_am->target_name) - 1] = '\0';
}

void AM_BUILD(build_type_t type, bool use_dependency)
{
    g_am->build_type = type;
    g_am->target_srcs.generate_deps = use_dependency;

    if (g_am->target_srcs.src_count == 0 &&
        g_am->target_srcs.src_dir[0] != '\0')
    {
        scan_dir_recursive(g_am->target_srcs.src_dir,
                           g_am->target_srcs.exclude_path);
    }

    if (!validate_build()) return;
    mkdir_recursive(g_am->target_dirs.build);

    // compile all source file
    const char *object_files[MAX_SRC];
    int obj_count = 0;
    if (!compile_sources(object_files, &obj_count)) return;

    // set extension
    char output_path[MAX_PATH];
    const char *prefix = "";
    const char *ext = "";
    get_output_ext(type, &prefix, &ext);

    snprintf(output_path, sizeof(output_path), "%s/%s%s%s",
             g_am->target_dirs.bin, prefix, g_am->target_name, ext);

    printf("Linking: %s\n", output_path);

    build_output(output_path, type, object_files, obj_count);

    // Clean up object file strings
    for (int i = 0; i < obj_count; ++i)
    {
        free((char *)object_files[i]);
    }

    print_sum(output_path, type);
}

void AM_GEN_DATABASE(void)
{
    if (g_am->build_type != BUILD_EXE && g_am->build_type != BUILD_SHARED)
        return;

    if (g_am->compdb_written) return;

    struct stat st;
    if (stat("compile_commands.json", &st) == 0) return;

    g_am->export_compdb = true;
    build_compdb();
    g_am->compdb_written = true;
}

void AM_PREBUILT_TO_SYSTEM(bool system_mode, const char *library_path,
                           const char *header_path, bool has_headers)
{
    if (!library_path)
    {
        fprintf(stderr,
                "AM_PREBUILT_TO_SYSTEM: library_path cannot be NULL.\n");
        return;
    }
    if (has_headers && !header_path)
    {
        fprintf(stderr, "AM_PREBUILT_TO_SYSTEM: has_header is true but "
                        "header_path is NULL.\n");
        return;
    }

    if (setup_install_paths(system_mode) != 0) return;

    const char *lib_name = pkg_lib_name(library_path);

    if (install_shared_library(library_path, lib_name) != 0)
    {
        perror("AM_PREBUILT_TO_SYSTEM: failed to install .so");
        return;
    }

    if (has_headers)
    {
        if (install_headers(header_path, lib_name) != 0)
        {
            perror("AM_PREBUILT_TO_SYSTEM: failed to install headers");
            return;
        }
    }

    printf("Installed %s.so%s (%s)\n", lib_name,
           has_headers ? " with public headers" : "",
           system_mode ? "system install" : "test install");
}

void AM_SET_OBJECT_LAYOUT(object_layout_t layout)
{
    g_am->is_mirrored = (layout == AM_MIRROR);
}

#endif // TWO_AM_BUILD_IMPL
#endif // TWO_AM_BUILDER_H
