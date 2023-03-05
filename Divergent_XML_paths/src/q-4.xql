let $doc := fn:doc("file:///home/rinderkn/Research/Divergent_XML_paths/src/doc-3.xml")
for $a in $doc//a,
    $b in $a//b,
    $c in $a//c
          except $a//$b//c
          except $a//c[descendant::b=$b
                       and descendant::b/@order=$b/@order]
return <disjoint>
       {(element {fn:node-name($a)} {$a/@order},
         element {fn:node-name($b)} {$b/@order},
         element {fn:node-name($c)} {$c/@order}) }
       </disjoint>
