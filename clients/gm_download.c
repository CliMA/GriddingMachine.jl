/* C entry point: gm_download <url> <output>. Integrity-aware tag downloads
   can use clients/download.py; this tiny ABI keeps C integrations portable. */
#include <stdlib.h>
#include <stdio.h>
int main(int n, char **v) { if (n != 3) return 2; char cmd[8192];
  int r=snprintf(cmd,sizeof(cmd),"python3 clients/download.py --url '%s' --output '%s'",v[1],v[2]);
  return r<0 || (size_t)r>=sizeof(cmd) ? 3 : system(cmd); }
