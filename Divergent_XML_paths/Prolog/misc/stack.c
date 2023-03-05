#include<stdlib.h>

typedef struct stack_ stack;
struct stack_ {
  char* item;
  stack* next;
};

int is_empty(stack* s) {
  return s == NULL? 1 : 0;
}

void push (stack** s, char* item) {
  stack* new_stack = malloc(sizeof(stack));
  (*new_stack).item = item;
  (*new_stack).next = *s;
  *s = new_stack;
}

char* pop (stack** s) {
  if (*s == NULL)
    return NULL;
  else {
    char* item = (**s).item;
    *s = (**s).next;
    return item;
  }
}

char* top (stack* s) {
  return (s == NULL)? NULL : (*s).item;
}

void print (stack* s) {
  if (s != NULL) {
    printf("%s ", (*s).item);
    print ((*s).next);
  }
}

void pop_all (stack* s) {
  if (s != NULL) {
    char* item = pop(&s);
    printf("%s ",item);
    free(item);
    pop_all(s);
  }
}

int main() {
  stack *s = NULL;
  push(&s, "foo");
  push(&s, "bar");
  push(&s, "baz");
  print(s);
  return 0;
}
