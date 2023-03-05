let $doc := fn:doc("file:///home/rinderkn/Research/Divergent_XML_paths/src/doc-1.xml")
for $a in $doc//a,
    $b in $doc//b,
    $c in $doc//c
return <disjoint>
        { (element {node-name($a)} {$a/@order},
           element {node-name($b)} {$b/@order},
           element {node-name($c)} {$c/@order})
        }
       </disjoint>
