%{
%}

(* End Of File *)

%token EOF

(* Keywords *)

%token For In Some Every Satisfies Return
%token If Then Else
%token Or And
%token To
%token Div Idiv Mod
%token Union Intersect Except
%token Instance Of Treat As Castable Cast
%token Eq Ne Lt Le Gt Ge
%token Is
%token Child Descendant Attribute Self Descendant_or_self
       Following_sibling Following Namespace
%token Parent Ancestor Preceding_sibling Preceding Ancestor_or_self
%token Empty_sequence Item Node Document_node Text Comment
       Processing_instruction Schema_attribute Element Schema_element
%token Typeswitch (* Unused but reserved *)

(* Symbols *)

%token WILD TIMES_OCC PLUS_OCC
%token COMMA PLUS MINUS TIMES
%token TIMES_COLON_NCNAME NCNAME_COLON_TIMES 
%token EQ NE LT LE GT GE
%token LT_LT GT_GT
%token SLASH SLASH_SLASH
%token COLON_COLON
%token AT VBAR
%token DOT DOT_DOT
%token LBRACKET RBRACKET LPAR RPAR
%token QMARK
%token DOLLAR

(* Litterals *)

%token <string * string>   QNAME (* Not a reserved keyword ??? *)
%token          <string>  NCNAME (* Not a reserved keyword *)
%token             <int> INTEGER (* Change to arbitrary precision *)
%token           <float> DECIMAL (* Change to arbitrary precision *)
%token           <float>  DOUBLE (* Make sure the precision is right *)
%token          <string>  STRING 
%token          <string> FUNNAME

(* Entry point *)

%start <int> main

%%

main: xpath EOF { 1 }

xpath: expr { }

expr:
  exprSingle            { }
| exprSingle COMMA expr { }

exprSingle:	
  forExpr        { }
| quantifiedExpr { }
| ifExpr         { }
| orExpr         { }

forExpr:
  For inClauses Return exprSingle { }

quantifiedExpr:
  Some  inClauses Satisfies exprSingle { }
| Every inClauses Satisfies exprSingle { } 

inClauses:
  varRef In exprSingle                 { }
| varRef In exprSingle COMMA inClauses { }

ifExpr:
  If LPAR expr RPAR Then exprSingle Else exprSingle { }

orExpr:
  andExpr           { }
| andExpr Or orExpr { }

andExpr:
  comparisonExpr             { }
| comparisonExpr And andExpr { }

comparisonExpr:
  rangeExpr                 { }
| rangeExpr Eq    rangeExpr { }
| rangeExpr Ne    rangeExpr { }
| rangeExpr Lt    rangeExpr { }
| rangeExpr Le    rangeExpr { }
| rangeExpr Gt    rangeExpr { }
| rangeExpr Ge    rangeExpr { }
| rangeExpr EQ    rangeExpr { }
| rangeExpr NE    rangeExpr { }
| rangeExpr LT    rangeExpr { }
| rangeExpr LE    rangeExpr { }
| rangeExpr GT    rangeExpr { }
| rangeExpr GE    rangeExpr { }
| rangeExpr Is    rangeExpr { }
| rangeExpr LT_LT rangeExpr { }
| rangeExpr GT_GT rangeExpr { }

rangeExpr:
  additiveExpr                 { }
| additiveExpr To additiveExpr { }

additiveExpr:
  multiplicativeExpr                    { }
| multiplicativeExpr PLUS  additiveExpr { }
| multiplicativeExpr MINUS additiveExpr { }

(* Never followed by COLON or LPAR *)
multiplicativeExpr:
  unionExpr                          { }
| unionExpr TIMES multiplicativeExpr { }
| unionExpr Div   multiplicativeExpr { }
| unionExpr Idiv  multiplicativeExpr { }
| unionExpr Mod   multiplicativeExpr { }

unionExpr:
  intersectExceptExpr                 { }
| intersectExceptExpr Union unionExpr { }
| intersectExceptExpr VBAR  unionExpr { }

intersectExceptExpr:
  instanceofExpr                               { }
| instanceofExpr Intersect intersectExceptExpr { }
| instanceofExpr Except    intersectExceptExpr { }

instanceofExpr:
  treatExpr                          { }
| treatExpr Instance Of sequenceType { }

treatExpr:
  castableExpr                       { }
| castableExpr Treat As sequenceType { }

castableExpr:
  castExpr                        { }
| castExpr Castable As singleType { }

castExpr:
  unaryExpr                    { }
| unaryExpr Cast As singleType { }

unaryExpr:
  plusMinus* valueExpr { }

plusMinus:
  PLUS  { }
| MINUS { }

valueExpr:
  pathExpr { }

(* xgc: leading-lone-slash *)
pathExpr:
  SLASH                         { }
| SLASH       relativePathExpr  { }
| SLASH_SLASH relativePathExpr  { }
| relativePathExpr              { }

relativePathExpr:
  stepExpr                              { }
| stepExpr SLASH       relativePathExpr { }
| stepExpr SLASH_SLASH relativePathExpr { }

stepExpr:
  filterExpr { }
| axisStep   { }

axisStep:
  reverseStep predicate* { }
| forwardStep predicate* { }

forwardStep:
  Child              COLON_COLON nodeTest { }
| Descendant         COLON_COLON nodeTest { }
| Attribute          COLON_COLON nodeTest { }
| Self               COLON_COLON nodeTest { }
| Descendant_or_self COLON_COLON nodeTest { }
| Following_sibling  COLON_COLON nodeTest { }
| Following          COLON_COLON nodeTest { }
| Namespace          COLON_COLON nodeTest { }
| AT nodeTest                             { }
| nodeTest                                { }

reverseStep:
  Parent            COLON_COLON nodeTest { }
| Ancestor          COLON_COLON nodeTest { }
| Preceding_sibling COLON_COLON nodeTest { }
| Preceding         COLON_COLON nodeTest { }
| Ancestor_or_self  COLON_COLON nodeTest { }
| DOT_DOT                                { }

(* Not preceded by LPAR *)
nodeTest:
  kindTest { }
| nameTest { }

nameTest:
  QNAME    { }
| wildcard { }

(* ws: explicit *)
(* Never followed by COLON *)
wildcard: 
  TIMES              { }
| NCNAME_COLON_TIMES { }
| TIMES_COLON_NCNAME { }

filterExpr:
  primaryExpr predicate* { }

predicate:
  LBRACKET expr RBRACKET { }

primaryExpr:
  INTEGER                   { }
| DECIMAL                   { }
| DOUBLE                    { }
| STRING                    { }
| varRef                    { }
| LPAR expr? RPAR           { }
| DOT                       { }
(* xgc: reserved-function-names *)
(* gn: parens *)
| FUNNAME LPAR expr? RPAR  { } 

varRef:
  DOLLAR QNAME { }

singleType:
  QNAME QMARK? { }

sequenceType:
  Empty_sequence LPAR RPAR     { }
| itemType                     { }
| itemType occurrenceIndicator { }

(* xgc: occurrence-indicators *)
(* Never followed by COLON, only preceded by RPAR, QNAME *)
occurrenceIndicator:
  QMARK     { }
| TIMES_OCC { } 
| PLUS_OCC  { }

itemType:
  kindTest       { }
| Item LPAR RPAR { }
| QNAME          { }

kindTest:
  documentTest                             { }
| elementTest                              { }
| attributeTest                            { }
| schemaElementTest                        { }
| Schema_attribute LPAR attributeName RPAR { }
| piTest                                   { }
| Comment LPAR RPAR                        { }
| Text LPAR RPAR                           { }
| Node LPAR RPAR                           { }

documentTest:
  Document_node LPAR RPAR                   { }
| Document_node LPAR elementTest RPAR       { }
| Document_node LPAR schemaElementTest RPAR { }

schemaElementTest:
  Schema_element LPAR elementName RPAR { }

piTest:
  Processing_instruction LPAR RPAR        { }
| Processing_instruction LPAR NCNAME RPAR { }
| Processing_instruction LPAR STRING RPAR { }

attributeTest:
  Attribute LPAR RPAR                              { }
| Attribute LPAR attributeName RPAR                { }
| Attribute LPAR TIMES RPAR                        { }
| Attribute LPAR attributeName COMMA typeName RPAR { }
| Attribute LPAR TIMES COMMA typeName RPAR         { }

elementTest:
  Element LPAR RPAR                                   { }
| Element LPAR elementName RPAR                       { }
| Element LPAR TIMES RPAR                             { }
| Element LPAR elementName COMMA typeName QMARK? RPAR { }
| Element LPAR TIMES COMMA typeName QMARK? RPAR       { }

attributeName:
  QNAME { }

elementName:
  QNAME { }

typeName:
  QNAME { }
