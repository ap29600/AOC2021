#include <stdio.h>

int main () {
  char cmd[100];
  int val;
  int x = 0;
  int y = 0;
  int aim = 0;

  while (scanf("%s %d", cmd, &val) != EOF) {
    switch (cmd[0]) {
      case 'f':
        x += val;
        y += val * aim;
        break;
      case 'b':
        return 1;
      case 'd':
        aim += val;
        break;
      case 'u':
        aim -= val;
        break;
    }
  }
  printf ("X: %d, Y: %d, RESULT: %d\n", x, y, x*y);
}
