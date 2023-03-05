let $doc := fn:doc("file:///home/rinderkn/Research/Divergent_XML_paths/src/doc-1.xml")
for $a in $doc//a,
    $b in $doc//b
          except $doc//$a//b
          except $doc//b[descendant::a=$a
                         and descendant::a/@order=$a/@order],
    $c in $doc//c
          except $doc//$a//c
          except $doc//c[descendant::a=$a
                         and descendant::a/@order=$a/@order]
          except $doc//$b//c
          except $doc//c[descendant::b=$b
                         and descendant::b/@order=$b/@order] 
return <disjoint> {(element {fn:node-name($a)} {$a/@order},
                    element {fn:node-name($b)} {$b/@order},
                    element {fn:node-name($c)} {$c/@order})
                  } 
       </disjoint>
