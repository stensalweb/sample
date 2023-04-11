#include <stdio.h>
#include <unistd.h>
#include <sys/file.h>

int main(int argc, char **argv){
  char *file = argv[1];
  int fd = open(file, O_RDONLY);
  if( fd < 0 ){
    perror(file);
    return 1;
  }
  int flag = argc == 2 ? LOCK_SH : LOCK_EX;
  
  if( flock(fd, flag) < 0 ){
    perror(file);
    return 1;
  }
  printf("locking '%s' as %s any char to unlock:", file, flag == LOCK_SH ? "shared":"x");
  getchar();

  flock(fd, LOCK_UN);
  close(fd);
  return 0;
}