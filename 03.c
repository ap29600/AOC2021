#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define L 12
#define N 1000

typedef struct {
  char s[L+1];
} line;

line lines[N] = {0};


#define MOST_FREQUENT 1
#define LEAST_FREQUENT 0

void dbg(line *v, int n) {
  printf("len: %d\n", n);
  for(int i = 0; i < n; i++)
    printf("%.*s\n", 12, v[i].s);
}

line *get_by_bit_freq(line*v, int n, int bit, int policy) {
  if (n == 1) {
    return &v[0];
  }
  if (bit == L) { 
    printf("ERR: no result after checking all bits\n");
    exit(1); 
  }
  if (n == 0) {
    printf("ERR: empty candidates list\n");
    exit(1);
  }

  // find the first occurrence of '1'.
  int split = 0;
  for(; split < n && v[split].s[bit] == '0'; split++);

  if (split == 0 || split == n) {
    printf("ERR: all strings start with the same digit");
      exit(1);
    // return get_by_bit_freq(v, n, bit+1, policy);
  }

  if (split * 2 > n) { // most frequent is 0
    if (policy == MOST_FREQUENT) {
      return get_by_bit_freq(v, split, bit + 1, policy);
    } else {
      return get_by_bit_freq(v + split, n - split, bit + 1, policy);
    }
  } else /* if ((split + 1) * 2 <= n ) */ { // most frequent is 1 or tie
    if (policy == MOST_FREQUENT) {
      return get_by_bit_freq(v + split, n - split, bit + 1, policy);
    } else {
      return get_by_bit_freq(v, split, bit + 1, policy);
    }
  }
}

int from_binary(line *l) {
  int result = 0;
  for (int i = 0; i < L; i++) {
    result |= (l->s[i] - '0') << (L - i - 1);
  }
  return result;
}


int main() {
  int endp = N-1;
  int startp = 0;

  for(int i = 0; i < N; i++) { scanf("%s", lines[i].s); }
  qsort(lines, N, sizeof(line), (__compar_fn_t)strcmp);
  line * l = get_by_bit_freq(lines, N, 0, MOST_FREQUENT);
  int oxygen = from_binary(l);
  printf("%s %d\n", l->s, oxygen);
  l = get_by_bit_freq(lines, N, 0, LEAST_FREQUENT);
  int co2 = from_binary(l);
  printf("%s %d\n", l->s, co2);

  printf("%d\n", oxygen * co2);
}

