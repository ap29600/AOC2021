#include<stdio.h>

int main() {
  int last[4];
  int count = 0;
  scanf("%d %d %d", last, &last[1], &last[2]);
  while (scanf("%d", &last[3]) != EOF) {
    if (last[3] > last[0])
      count ++;
    last[0] = last[1];
    last[1] = last[2];
    last[2] = last[3];
  }
  printf("%d\n", count);
}
