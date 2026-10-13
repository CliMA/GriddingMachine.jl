/* Enable POSIX declarations under strict C99 compilation. */
#ifndef _WIN32
#define _POSIX_C_SOURCE 200809L
#endif
/* Launch the shared downloader with legacy URL/OUTPUT or Python-style options. */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <process.h>
#include <windows.h>
#else
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif
#endif

/* Locate installed clients beside the executable; GM_DOWNLOADER overrides this. */
static int exists(const char *path) {
    FILE *file = fopen(path, "rb");
    if (!file) return 0;
    fclose(file);
    return 1;
}

static const char *find_script(const char *program, char *buffer, size_t capacity) {
    const char *override = getenv("GM_DOWNLOADER");
    char executable[8192], *slash;
    if (override && *override) return override;
#ifdef _WIN32
    DWORD count = GetModuleFileNameA(NULL, executable, sizeof(executable));
    if (!count || count >= sizeof(executable)) executable[0] = '\0';
#elif defined(__APPLE__)
    uint32_t count = sizeof(executable);
    if (_NSGetExecutablePath(executable, &count) != 0) executable[0] = '\0';
#else
    ssize_t count = readlink("/proc/self/exe", executable, sizeof(executable) - 1);
    if (count > 0) executable[count] = '\0'; else executable[0] = '\0';
#endif
    if (!*executable) snprintf(executable, sizeof(executable), "%s", program);
    slash = strrchr(executable, '/');
#ifdef _WIN32
    {
        char *backslash = strrchr(executable, '\\');
        if (backslash && (!slash || backslash > slash)) slash = backslash;
    }
#endif
    if (slash) {
        *slash = '\0';
        if (snprintf(buffer, capacity, "%s/download.py", executable) < (int)capacity && exists(buffer))
            return buffer;
        if (snprintf(buffer, capacity, "%s/clients/download.py", executable) < (int)capacity && exists(buffer))
            return buffer;
    }
    /* Retain root-directory invocation for binaries built outside clients/. */
    return "clients/download.py";
}

#ifdef _WIN32
/* The CRT spawn API joins arguments; quote them using Windows backslash rules. */
static char *quote_windows(const char *value) {
    size_t length = strlen(value), slashes = 0;
    char *result = malloc(length * 2 + 3), *out;
    if (!result) return NULL;
    out = result;
    *out++ = '"';
    for (; *value; ++value) {
        if (*value == '\\') {
            ++slashes;
            continue;
        }
        if (*value == '"') {
            while (slashes) { *out++ = '\\'; *out++ = '\\'; --slashes; }
            *out++ = '\\';
        } else {
            while (slashes) { *out++ = '\\'; --slashes; }
        }
        *out++ = *value;
    }
    while (slashes) { *out++ = '\\'; *out++ = '\\'; --slashes; }
    *out++ = '"';
    *out = '\0';
    return result;
}
#endif

int main(int argc, char **argv) {
    const char *python = getenv("GM_PYTHON");
    char script_buffer[8192];
    const char *script = find_script(argv[0], script_buffer, sizeof(script_buffer));
    char **arguments;
    int count = 0, first = 1, result = 1;
    if (argc < 2) {
        fprintf(stderr, "usage: gm_download URL OUTPUT [OPTIONS] or gm_download --tag TAG --catalog FILE --output FILE\n");
        return 2;
    }
    /* Consume a wrapper-specific script override and forward other options verbatim. */
    arguments = calloc((size_t)argc + 7, sizeof(*arguments));
    if (!arguments) return 3;
#ifdef _WIN32
    if (!python || !*python) python = "python";
#else
    if (!python || !*python) python = "python3";
#endif
    arguments[count++] = (char *)python;
    arguments[count++] = (char *)script;
    if (argv[1][0] != '-') {
        if (argc < 3) { free(arguments); return 2; }
        arguments[count++] = "--url";
        arguments[count++] = argv[1];
        arguments[count++] = "--output";
        arguments[count++] = argv[2];
        first = 3;
    }
    for (int i = first; i < argc; ++i) {
        if (strcmp(argv[i], "--script") == 0) {
            if (++i == argc) { free(arguments); return 2; }
            script = argv[i];
            arguments[1] = (char *)script;
        } else {
            arguments[count++] = argv[i];
        }
    }
    if (!exists(script)) {
        fprintf(stderr, "downloader not found: %s; set GM_DOWNLOADER or --script\n", script);
        free(arguments);
        return 2;
    }
#ifdef _WIN32
    /* Use an argument vector, avoiding cmd.exe expansion of URLs and file paths. */
    {
        char **quoted = calloc((size_t)count + 1, sizeof(*quoted));
        intptr_t status;
        if (!quoted) { free(arguments); return 3; }
        for (int i = 0; i < count; ++i) {
            quoted[i] = quote_windows(arguments[i]);
            if (!quoted[i]) {
                for (int j = 0; j < i; ++j) free(quoted[j]);
                free(quoted);
                free(arguments);
                return 3;
            }
        }
        status = _spawnvp(_P_WAIT, python, (const char *const *)quoted);
        for (int i = 0; i < count; ++i) free(quoted[i]);
        free(quoted);
        if (status == -1) perror("unable to start Python 3");
        result = status == -1 ? 127 : (int)status;
    }
#else
    /* POSIX exec passes arguments directly without a shell; retain Python's exit code. */
    {
        pid_t child = fork();
        int status;
        if (child == -1) {
            perror("unable to fork");
            result = 127;
        } else if (child == 0) {
            execvp(python, arguments);
            perror("unable to start Python 3");
            _exit(127);
        } else {
            pid_t waited;
            do { waited = waitpid(child, &status, 0); } while (waited == -1 && errno == EINTR);
            if (waited == -1) { perror("unable to wait for Python 3"); result = 127; }
            else result = WIFEXITED(status) ? WEXITSTATUS(status) : 1;
        }
    }
#endif
    free(arguments);
    return result;
}
