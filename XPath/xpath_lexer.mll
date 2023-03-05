{
(* Operator '*' => [[Operator]] WILD
       '::' '*' => COLON_COLON WILD
        '@' '*' => AT(WILD)
       '//' '*' => SLASH_SLASH WILD    ???????

   if '@' QName 
   then if '(' 
        then QName = attribute comment document-node element
                     empty-sequence if item node
                     processing-instruction schema-attribute
                     schema-element text typeswitch
        and => AT(Attribute | Comment | ...)
        else syntax error
   else => AT(QName)

   '*'':'ncName => TIMES_COLON_NCNAME
   ncName':''*' => NCNAME_COLON_TIMES

   ncName '(' when ncName != attribute comment document-node element
                             empty-sequence if item node
                             processing-instruction schema-attribute
                             schema-element text typeswitch
                          => FUNNAME(ncName)
   ncName':'ncName '('    => FUNNAME(ncName':'ncName)

exception Open_comment;

let in_path = ref (false);

*)

}

let ws      = [' ' '\t' '\r' '\n']
let letter  = ['a'-'z' 'A'-'Z']
let digit   = ['0'-'9']
let ncName  = (letter | '_') (letter | digit | '.' | '-' | '_')*
let qName   = (ncName ':')? ncName
let integer = digit+
let decimal = ("." integer) | (integer "." integer?)
let	double  = (integer | decimal) [eE] [+-]? integer
(*let	string = ('"' ('""' | [^"])* '"') | ("'" ("''" | [^'])* "'") *)

rule token = parse
  ws     { token lexbuf }
| "(:"   { in_comment lexbuf 1 }
| ncName { __qName lexbuf (Lexing.lexeme lexbuf) }

and _qName = parse
  ':'     { localname lexbuf }
| ws* '(' { fun funname -> FUNNAME(funname) (* '(' buffered ?? *) }
| _       { fun name -> NCNAME(name) }

and localname = parse
  ncName { fun prefix -> QNAME(prefix,Lexing.lexeme lexbuf) }

and in_comment = parse
  ":)" { fun depth -> if depth = 1 then token lexbuf
                      else in_comment lexbuf (depth-1)
       }
| "(:" { fun depth -> in_comment lexbuf (depth+1) }
| eof  { raise Open_comment }
| _    { in_comment lexbuf }


{

}
