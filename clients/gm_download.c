/* C entry point: gm_download <url> <output>. Integrity-aware tag downloads
   can use clients/download.py; this tiny ABI keeps C integrations portable. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <process.h>
#else
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#endif

int main(int n, char **v) {
  const char *python = getenv("GM_PYTHON");
  if (n != 3) {
    fprintf(stderr, "usage: gm_download URL OUTPUT\n");
    return 2;
  }
#ifdef _WIN32
  if (python == NULL || *python == '\0') python = "python";
  {
    char *url;
    char *output;
    intptr_t status;
    if (strchr(v[1], '"') != NULL || strchr(v[2], '"') != NULL) {
      fprintf(stderr, "double quotes are not supported in arguments\n");
      return 2;
    }
    url = malloc(strlen(v[1]) + 3);
    output = malloc(strlen(v[2]) + 3);
    if (url == NULL || output == NULL) {
      free(url);
      free(output);
      return 3;
    }
    sprintf(url, "\"%s\"", v[1]);
    sprintf(output, "\"%s\"", v[2]);
    status = _spawnlp(_P_WAIT, python, python, "clients/download.py",
                      "--url", url, "--output", output, NULL);
    free(url);
    free(output);
    if (status == -1) {
      perror("unable to start Python 3");
      return 127;
    }
    return status == 0 ? 0 : 1;
  }
#else
  if (python == NULL || *python == '\0') python = "python3";
  {
    pid_t child = fork();
    int status;
    if (child == -1) {
      perror("unable to fork");
      return 127;
    }
    if (child == 0) {
      execlp(python, python, "clients/download.py", "--url", v[1],
             "--output", v[2], (char *)NULL);
      perror("unable to start Python 3");
      _exit(127);
    }
    if (waitpid(child, &status, 0) == -1) {
      perror("unable to wait for Python 3");
      return 127;
    }
    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
  }
#endif
}
