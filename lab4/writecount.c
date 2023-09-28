#include "types.h"
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[]) {
  if (argc > 1) {
    exit();
  }


  printf(1, "%d\n", writecount());
 
  exit();
}
