#include "types.h"
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[]) {
  if (argc > 2) {
    exit();
  }


  printf(1, "%d\n", setwritecount(atoi(argv[1])));
 
  exit();
}
