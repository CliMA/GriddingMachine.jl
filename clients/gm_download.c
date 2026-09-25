/* C entry point: gm_download <url> <output>. Integrity-aware tag downloads
   can use clients/download.py; this tiny ABI keeps C integrations portable. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int shell_quote(char *dst, size_t capacity, const char *src) {
  size_t used = 0;
  if (capacity < 3) return 0;
  dst[used++] = '\'';
  for (const char *p = src; *p != '\0'; ++p) {
    if (*p == '\'') {
      if (used + 4 >= capacity) return 0;
      memcpy(dst + used, "'\\''", 4);
      used += 4;
    } else {
      if (used + 1 >= capacity) return 0;
      dst[used++] = *p;
    }
  }
  if (used + 2 > capacity) return 0;
  dst[used++] = '\'';
  dst[used] = '\0';
  return 1;
}

int main(int n, char **v) {
  if (n != 3) return 2;
  char url[8192], output[8192], cmd[17000];
  if (!shell_quote(url, sizeof(url), v[1]) ||
      !shell_quote(output, sizeof(output), v[2])) return 3;
  int r = snprintf(cmd, sizeof(cmd),
                   "python3 clients/download.py --url %s --output %s",
                   url, output);
  return r < 0 || (size_t)r >= sizeof(cmd) ? 3 : system(cmd);
}
