%{
#include<string.h>
#include<stdlib.h>

typedef struct {
  char* name;
  int start;
} otag;

typedef struct stack_ stack;
struct stack_ {
  otag tag;
  stack* next;
};

void print_tag (otag tag) {
  printf("(%s,%d)", tag.name, tag.start);
}

void print_triple (otag tag, int end) {
  printf("(%s,%d,%d)", tag.name, tag.start, end);
}

int is_empty(stack* s) {
  return s == NULL? 1 : 0;
}

void push (stack** s, otag tag) {
  stack* new_stack_ptr = malloc(sizeof(stack));
  (*new_stack_ptr).tag = tag;
  (*new_stack_ptr).next = *s;
  *s = new_stack_ptr;
}

otag pop (stack** s) {
  otag tag = (**s).tag;
  *s = (**s).next;
  return tag;
}

otag* top (stack* s) {
  return (s == NULL)? NULL : &((*s).tag);
}

void print (stack* s) {
  if (s != NULL) {
    print_tag((*s).tag);
    print((*s).next);
  }
}

void pop_all (stack* s) {
  if (s != NULL) {
    otag tag = pop(&s);
    print_tag(tag);
    free(tag.name);
    pop_all(s);
  }
}

void free_stack (stack* s) {
  if (s != NULL) {
    stack* sub_stack = (*s).next;
    free((*s).tag.name);
    free_stack(sub_stack);
  }
}

char* extract_tag_name (char* src) {
  int len = strlen(src);
  char* tag_name = malloc(len-1);
  tag_name[len-1] = '\0';
  strncpy(tag_name, src+1, len-2);
  return tag_name;
}

int tag_count=0;

stack* tag_stack = NULL;
%}
letter  [A-Za-z]
digit   [0-9]
alpha   ({letter}|{digit})
ident   {letter}([_]*{alpha})*
opening "<"{ident}">"
closing "</"{ident}">"
%%
{opening} { char* tag_name = extract_tag_name(yytext);
            otag tag;
            tag.name=tag_name;
            tag.start=tag_count;
            push(&tag_stack, tag);
            tag_count++;
          }
{closing} { char* tag_name = extract_tag_name(yytext);
            otag tag; 
	    tag = pop(&tag_stack);
            print_triple(tag, tag_count);
            free(tag.name);
            tag_count++; 
          }
.         
%%
int main (int argc, char** argv) {
  ++argv, --argc; /* Skip over programme name */
  if (argc > 0)
    yyin = fopen(argv[0], "r");
  else
    yyin = stdin;

  yylex();
  /*  print(tag_stack);
  printf("\n");
  pop_all(tag_stack);
  free_stack(tag_stack);
  */
  return 0;
}
