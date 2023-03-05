let $doc := fn:doc("file:///home/rinderkn/Research/Divergent_XML_paths/src/doc-1.xml")
for $a in $doc//a,
    $c in $doc//c 
          except $doc//$a//c 
          except $doc//c[descendant::a=$a
                         and descendant::a/@order=$a/@order]
return <disjoint>
       { (element {node-name($a)} {$a/@order},
          element {node-name($c)} {$c/@order}) }
       </disjoint>
