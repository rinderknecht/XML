<?xml version="1.0" encoding="iso-8859-1"?>

<!--
This transform is a library of XSL functions implementing red-black
trees, as described by Chris Okasaki in his book __Purely Functional
Data Structures__ (sec. 3.3, Cambridge, 1998) or his paper __Red-Black
Trees in a Functional Setting__ (Functional Pearls, J. Functional
Programming, 1(1), 1993).

Red-back trees are balanced binary search trees, with nodes of two
kinds: red and black. Two invariants hold:

  Invariant 1. No red node has a red child.
  Invariant 2. Every path from the root to a leaf contains the same
               number of black nodes.

As a consequence, the longest path from root to leaf is, at worst,
twice as long as the shortest: this is the balancing property, which
is not so tight as with Adelson-Velskii and Landis' trees (AVL trees),
but still makes red-black trees very efficient in practice.

Currently the exported functions are:

  rbt:insert
  rbt:get
  rbt:merge    (UNTESTED)
  rbt:incr
  rbt:size     (UNTESTED)

The exported variables are

  rbt:empty_tree
  rbt:empty_node

Other templates and functions are for internal use only.

The definition of Chris Okasaki is meant for a statically strongly
typed functional language (e.g., Haskell or ML). As a consequence, the
values correspond to ranked trees, i.e., the data contructors have a
constant number of arguments. We prefer to take advantage of the
unranked trees which are the model of XML (i.e, a given element can
appear in document with a variable number of children). The benefit is
that empty leaves are not constructed, while they must be in a
ranked setting (although constant constructors are often shared by the
run-time of most modern compilers, as OCaml).

The following internal DTD fragment describes the data structure. The
type of red-black trees is represented by the element rbt:t. Nodes are
of two kinds: left or right. If left, they are represented by element
rbt:left, otherwise rbt:right. The former corresponds to nodes which
are left siblings, whilst the latter corresponds to right
siblings. This distinction stems from the unrankedness we chose by
design: a node has a variable number of children, which, consequently,
must be referred to by names which denote their position, left or
right (if ranked, the position would be enough and one kind of node,
i.e., one name, would suffice). This leads to an arbitrary choice
for the root, since the root has no sibling. We choose to make the
root a left node. If a tree is empty, it is denoted by a rbt:empty
element, children of rbt:t. Note that rbt:empty can only appear as a
child of rbt:t.

Left and right nodes have exactly the same structure. Nodes contain a
key (rbt:key), some data (rbt:data), an optional left subtree
(rbt:left) and possibly a right subtree (rbt:right). For example, a
leaf has no subtrees but contains data (beware of different
conventions). The nodes have two mandatory attributes: `colour' and
`size'. The former must either be `red' or `black' (as expected); the
latter's value is the number of nodes of the tree whose root the node
is. The `size' attribute is only used to access nodes by rank in
worst-time logarithmic time.

The functions are wrappers around templates, and only the functions
should be used from outside.

The functions of this transform are parameterised to serve the various
needs of unknown callers (clients). For instance, depending on the
nature of the keys, comparisons of keys should be provided by the
caller. To achieve this higher-order requisite, which XSL does not
allow directly, a workaround must be used. We use the method proposed
by Dimitre Novatchev (http://fxsl.sf.net), consisting in passing as
argument a distinguishing element instead of a function, and
application of this fake functional argument is done by matching a
template provided by the caller (where the computation is done, e.g.,
the comparison of two keys). The application (hof:apply) of such
special arguments, which is defined in the transform
`higher-order.xsl'.
-->

<!DOCTYPE xsl:transform [
  <!ELEMENT rbt:t     (rbt:empty | rbt:left)>
  <!ELEMENT rbt:empty EMPTY>
  <!ELEMENT rbt:left  (rbt:key,rbt:data,(rbt:left)?,(rbt:right)?)>
  <!ATTLIST rbt:left  colour (red | black) #REQUIRED
                      size   CDATA         #REQUIRED>
  <!ELEMENT rbt:right (rbt:key,rbt:data,(rbt:left)?,(rbt:right)?)>
  <!ATTLIST rbt:right colour (red | black) #REQUIRED
                      size   CDATA         #REQUIRED>
  <!ELEMENT rbt:key   ANY>
  <!ELEMENT rbt:data  ANY>
]>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:hof="file://higher-order.xsl"
               xmlns:rbt="file://red-black.xsl"
               exclude-result-prefixes="xs hof rbt">

  <xsl:import href="higher-order.xsl"/>

<!-- ==================================================================== -->
<!-- The empty tree and the empty node -->

  <xsl:variable name="rbt:empty_tree" as="element(rbt:t)">
    <rbt:t><rbt:empty/></rbt:t>
  </xsl:variable>

  <xsl:variable name="rbt:empty_node" as="element(rbt:empty)">
    <rbt:empty/>
  </xsl:variable>

<!-- ==================================================================== -->
<!-- Balancing the tree

There are two kinds of templates in this section: the one flipping a
node from left to right and from right to left, and the templates
which re-balance the tree after an insertion, if necessary.

The balancing follows exactly the clever cases of Chris Okasaki as
given in his published figure (p.27 in the book).

Note that the patterns could be 50% shorter, had the XPath syntax
allow "(rbt:left|rbt:right)[...]".
-->

  <!-- Flipping -->

  <xsl:template match="rbt:left" mode="rbt:flip">
    <rbt:right>
      <xsl:sequence select="@*,*"/>
    </rbt:right>
  </xsl:template>

  <xsl:template match="rbt:right" mode="rbt:flip">
    <rbt:left>
      <xsl:sequence select="@*,*"/>
    </rbt:left>
  </xsl:template>

  <!-- This the wrapper around the above templates -->

  <xsl:function name="rbt:flip">
    <xsl:param name="node"/>
    <xsl:apply-templates select="$node" mode="rbt:flip"/>
  </xsl:function>

  
  <!-- Balancing case A

             z(black)               y(red)
             /   \                  /   \
          y(red)  d           x(black) z(black)
          /   \        ==>       / \     / \
       x(red)  c                a   b   c   d 
       /  \
      a    b

   Note how `c', which is a right sibling (rbt:right) must be
   transformed into a left sibling (rbt:left), by means of rbt:flip.
  -->

  <xsl:template match="rbt:left[@colour eq 'black'][rbt:left[@colour eq 'red'][rbt:left[@colour eq 'red']]] | rbt:right[@colour eq 'black'][rbt:left[@colour eq 'red'][rbt:left[@colour eq 'red']]]" mode="rbt:balance">
    <xsl:variable name="z_size"
                  select="1 + (rbt:left/rbt:right/@size,0)[1]
                            + (rbt:right/@size,0)[1]"/>
    <xsl:copy>
      <xsl:attribute name="colour" select="'red'"/>
      <xsl:attribute name="size"
                     select="1 + (rbt:left/rbt:left/@size,0)[1] + $z_size"/>
      <xsl:sequence select="rbt:left/(rbt:key,rbt:data)"/>
      <rbt:left colour="black">
        <xsl:sequence select="rbt:left/rbt:left/(@size,*)"/>
      </rbt:left>
      <rbt:right size="{$z_size}">
        <xsl:sequence select="@colour,rbt:key,rbt:data,
                              rbt:flip(rbt:left/rbt:right),rbt:right"/>
      </rbt:right>
    </xsl:copy>
  </xsl:template>

<!-- Balancing case B

          z(black)                  y(red)
          /    \                    /   \
       x(red)   d             x(black) y(black)
       /  \            ==>       / \     / \
      a  y(red)                 a   b   c   d
          /  \
         b    c

     Note how `b' and `c', respectively left (rbt:left) and right
     (rbt:right) siblings, must be transformed into right and left
     siblings.
-->

  <xsl:template match="rbt:left[@colour eq 'black'][rbt:left[@colour eq 'red'][rbt:right[@colour eq 'red']]] | rbt:right[@colour eq 'black'][rbt:left[@colour eq 'red'][rbt:right[@colour eq 'red']]]" mode="rbt:balance">
    <xsl:variable name="x_size"
                  select="1 + (rbt:left/rbt:left/@size,0)[1]
                            + (rbt:left/rbt:right/rbt:left/@size,0)[1]"/>
    <xsl:variable name="z_size"
                  select="1 + (rbt:left/rbt:right/rbt:right/@size,0)[1]
                            + (rbt:right/@size,0)[1]"/>
    <xsl:copy>
      <xsl:attribute name="colour" select="'red'"/>
      <xsl:attribute name="size" select="1 + $x_size + $z_size"/>
      <xsl:sequence select="rbt:left/rbt:right/(rbt:key,rbt:data)"/>
      <rbt:left colour="black" size="{$x_size}">
        <xsl:sequence
            select="rbt:left/(rbt:key,rbt:data,rbt:left,rbt:flip(rbt:right/rbt:left))"/>
      </rbt:left>
      <rbt:right size="{$z_size}">
        <xsl:sequence select="@colour,rbt:key,rbt:data,
                              rbt:flip(rbt:left/rbt:right/rbt:right),rbt:right"/>
      </rbt:right>
    </xsl:copy>
  </xsl:template>

<!-- Balancing case C

        x(black)                 y(red)
         /  \                     /  \
        a  z(red)           x(black) z(black)
            /  \     ==>       / \    / \
        y(red)  d             a   b  c   d
         / \
        b   c

     Note how `b' and `c', respectively left (rbt:left) and right
     (rbt:right) siblings, must be transformed into right and left
     siblings
-->

  <xsl:template match="rbt:left[@colour eq 'black'][rbt:right[@colour eq 'red'][rbt:left[@colour eq 'red']]] | rbt:right[@colour eq 'black'][rbt:right[@colour eq 'red'][rbt:left[@colour eq 'red']]]" mode="rbt:balance">
    <xsl:variable name="x_size"
                  select="1 + (rbt:left/@size,0)[1] 
                            + (rbt:right/rbt:left/rbt:left/@size,0)[1]"/>
    <xsl:variable name="z_size"
                  select="1 + (rbt:right/rbt:left/rbt:right/@size,0)[1]
                            + (rbt:right/rbt:right/@size,0)[1]"/>
    <xsl:copy>
      <xsl:attribute name="colour" select="'red'"/>
      <xsl:attribute name="size" select="1 + $x_size + $z_size"/>
      <xsl:sequence select="rbt:right/rbt:left/(rbt:key,rbt:data)"/>
      <rbt:left size="{$x_size}">
        <xsl:sequence select="@colour,rbt:key,rbt:data,
                              rbt:left,rbt:flip(rbt:right/rbt:left/rbt:left)"/>
      </rbt:left>
      <rbt:right colour="black" size="{$z_size}">
        <xsl:sequence
             select="rbt:right/(rbt:key,rbt:data,rbt:flip(rbt:left/rbt:right),rbt:right)"/>
      </rbt:right>
    </xsl:copy>
  </xsl:template>
  
<!-- Balancing case D

         x(black)                 y(red)
          /  \                     /  \
         a  y(red)           x(black) z(black)
             /  \       ==>     / \    / \
            b  z(red)          a   b  c   d
                /  \
               c    d

   Note how `b', which is a left sibling (rbt:left) must be
   transformed into a right sibling (rbt:right), by means of rbt:flip.
 -->

  <xsl:template match="rbt:left[@colour eq 'black'][rbt:right[@colour eq 'red'][rbt:right[@colour eq 'red']]] | rbt:right[@colour eq 'black'][rbt:right[@colour eq 'red'][rbt:right[@colour eq 'red']]]" mode="rbt:balance">
    <xsl:variable name="x_size"
                  select="1 + (rbt:left/@size,0)[1]
                            + (rbt:right/rbt:left/@size,0)[1]"/>
    <xsl:copy>
      <xsl:attribute name="colour" select="'red'"/>
      <xsl:attribute name="size"
                     select="1 + $x_size + (rbt:right/rbt:right/@size,0)[1]"/>
      <xsl:sequence select="rbt:right/(rbt:key,rbt:data)"/>
      <rbt:left size="{$x_size}">
        <xsl:sequence select="@colour,rbt:key,rbt:data,
                              rbt:left,rbt:flip(rbt:right/rbt:left)"/>
      </rbt:left>
      <rbt:right colour="black">
        <xsl:sequence select="rbt:right/rbt:right/(@size,*)"/>
      </rbt:right>
    </xsl:copy>
  </xsl:template>

<!-- Otherwise: No need to rebalance, just update the size. -->

  <xsl:template match="rbt:left|rbt:right" mode="rbt:balance">
    <xsl:copy>
      <xsl:attribute name="size"
           select="1 + (rbt:left/@size,0)[1] + (rbt:right/@size,0)[1]"/>
      <xsl:sequence select="@colour,*"/>
    </xsl:copy>
  </xsl:template>

<!-- ==================================================================== -->
<!-- Inserting a node

The rbt:insert function implements the insertion in a red-black tree,
which is simply the insertion in a classic binary search tree
(top-down), followed by a rebalancing (bottom-up).

The cost in the worst case is logarithmic in the number of nodes of the
tree.

The extra difficulty here is due to the unranked design. That is why
there are two templates to insert into an empty node (rbt:empty),
depending whether the resulting node has to be a left or a right
sibling. The two templates are distinguished by a specific mode,
rbt:add_left or rbt:add_right.
-->

  <xsl:template match="rbt:empty" mode="rbt:add_left">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <rbt:left colour="red" size="1">
      <rbt:key><xsl:sequence select="$key"/></rbt:key>
      <rbt:data><xsl:sequence select="$data"/></rbt:data>
    </rbt:left>
  </xsl:template>

  <xsl:template match="rbt:empty" mode="rbt:add_right">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <rbt:right colour="red" size="1">
      <rbt:key><xsl:sequence select="$key"/></rbt:key>
      <rbt:data><xsl:sequence select="$data"/></rbt:data>
    </rbt:right>
  </xsl:template>

  <!--
  This template inserts the piece of data $data with key $key in the
  tree whose root is matched by the pattern (note that the root of the
  whole tree is arbitrarily a rbt:left element). The comparison
  between keys is specified by $comp. It must be a three-way
  comparison leading to values -1, 0 or 1, if the first key is,
  respectively, smaller, equal or greater than the second. Notice how
  an empty node is used when creating the leaf (insertion is done at
  the leaves). We use the global variable $rbt:empty_node to avoid
  recreating an empty node at each insertion. When two keys are equal,
  what should be done with the data in the node and the data to be
  inserted? This is specified by argument $comb (`combine'). For
  example, both informations could be stored in the existing node, in
  a certain order, or the new one could be discarded etc. depending on
  the caller's need.
  -->

  <xsl:template match="rbt:left|rbt:right" mode="rbt:add_left rbt:add_right">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="comp" as="element()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="comb" as="element()"/>
    <xsl:variable name="three_way" as="xs:integer"
                  select="hof:apply($comp,$key,rbt:key/node())"/>
    <xsl:choose>
      <xsl:when test="$three_way lt 0">
        <xsl:variable name="new_node">
          <xsl:copy>
            <xsl:sequence select="@*,rbt:key,rbt:data"/>
            <xsl:apply-templates select="(rbt:left,$rbt:empty_node)[1]" 
                                 mode="rbt:add_left">
              <xsl:with-param name="key"  select="$key"/>
              <xsl:with-param name="comp" select="$comp"/>
              <xsl:with-param name="data" select="$data"/>
              <xsl:with-param name="comb" select="$comb"/>
            </xsl:apply-templates>
            <xsl:sequence select="rbt:right"/>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$new_node" mode="rbt:balance"/>
      </xsl:when>
      <xsl:when test="$three_way gt 0">
        <xsl:variable name="new_node">
          <xsl:copy>
            <xsl:sequence select="@*,rbt:key,rbt:data,rbt:left"/>
            <xsl:apply-templates select="(rbt:right,$rbt:empty_node)[1]"
                                 mode="rbt:add_right">
              <xsl:with-param name="key"  select="$key"/>
              <xsl:with-param name="comp" select="$comp"/>
              <xsl:with-param name="data" select="$data"/>
              <xsl:with-param name="comb" select="$comb"/>
            </xsl:apply-templates>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$new_node" mode="rbt:balance"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:sequence select="@*,rbt:key"/>
          <rbt:data>
            <xsl:sequence select="hof:apply($comb,rbt:data/node(),$data)"/>
          </rbt:data>
          <xsl:sequence select="rbt:left,rbt:right"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  This is the wrapper around the templates above. Notice that the root
  of the tree must be black in order to preserve Invariant 2 (see
  above). Code is saved by forcing the root to be black, without prior
  checking the colour.
  -->

  <xsl:function name="rbt:insert" as="element(rbt:t)">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="comp" as="element()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="comb" as="element()"/>
    <xsl:variable name="new_root" as="element(rbt:left)">
      <xsl:apply-templates select="$tree/element()" mode="rbt:add_left">
        <xsl:with-param name="key"  select="$key"/>
        <xsl:with-param name="comp" select="$comp"/>
        <xsl:with-param name="data" select="$data"/>
        <xsl:with-param name="comb" select="$comb"/>
      </xsl:apply-templates>
    </xsl:variable>
    <rbt:t>
      <rbt:left colour="black">
        <xsl:sequence select="$new_root/(@size,*)"/>
      </rbt:left>
    </rbt:t>
  </xsl:function>

<!-- ==================================================================== -->
<!-- Accessing nodes by rank

The value `rbt:get($tree,rank)', where `$tree' is a red-black tree and
`$rank' an integer, is the data associated with the node in `$tree' at
the rank `$rank': rank `1' means the smallest node, `2' the following
in increasing key order etc. In the worst case, this operation is
logarithmic in the number of nodes.

If the rank does not correspond to a node, an empty sequence is
returned. 
-->

  <xsl:template match="rbt:empty" mode="rbt:get"/>

  <xsl:template match="rbt:left|rbt:right" mode="rbt:get">
    <xsl:param name="rank" as="xs:integer"/>
    <xsl:variable name="root_index" as="xs:integer"
                  select="1 + (xs:integer(rbt:left/@size),0)[1]"/>
    <xsl:choose>
      <xsl:when test="$rank lt $root_index">
        <xsl:apply-templates select="rbt:left" mode="rbt:get">
          <xsl:with-param name="rank" select="$rank"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$rank gt $root_index">
        <xsl:apply-templates select="rbt:right" mode="rbt:get">
          <xsl:with-param name="rank" select="$rank - $root_index"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="current()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- The wrapper to be called from outside the transform -->

  <xsl:function name="rbt:get" as="element()*">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:param name="rank" as="xs:integer"/>
    <xsl:apply-templates select="$tree/element()" mode="rbt:get">
      <xsl:with-param name="rank" select="$rank"/>
    </xsl:apply-templates>
  </xsl:function>

<!-- ==================================================================== -->
<!-- Accessing the size -->

  <xsl:template match="rbt:empty" mode="rbt:size">
    <xsl:sequence select="0"/>
  </xsl:template>

  <xsl:template match="rbt:left|rbt:right" mode="rbt:size">
    <xsl:sequence select="@size"/>
  </xsl:template>

  <xsl:function name="rbt:size" as="xs:integer">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:apply-templates select="$tree/element()" mode="rbt:size"/>
  </xsl:function>

<!-- ==================================================================== -->
<!-- Merging two trees 

The value `rbt:merge($tree1,$tree2,$comp,$comb)' is a red-black tree
containing the data of red-black tree `$tree1' and `$tree2'.

The nodes in both trees must have the same kind of key and comparison
function `$comp'. When a node in `$tree1' has the same key as a node
in `$tree2', the function associated to element `$comb' is called, as
in rbt:insert.

The merge is done by visiting (by increasing order of the keys) the
nodes of the smaller tree and adding them to the bigger tree. Thus, if
n1 is the size of `$tree1' and n2 the size of `$tree2', the cost is
O(min(n1,n2) * log(max(n1,n2))).
-->

  <xsl:template match="rbt:empty" mode="rbt:merge2">
    <xsl:param name="root1" as="element(rbt:left)"/>
    <xsl:param name="comp"  as="element()"/>
    <xsl:param name="comb"  as="element()"/>
    <xsl:sequence select="$root1"/>
  </xsl:template>

  <xsl:template match="rbt:left|rbt:right" mode="rbt:merge2">
    <xsl:param name="root1" as="element(rbt:left)"/>
    <xsl:param name="comp"  as="element()"/>
    <xsl:param name="comb"  as="element()"/>
    <xsl:variable name="prefix" as="element(rbt:left)">
      <xsl:apply-templates select="(rbt:left,$rbt:empty_node)[1]" 
                           mode="rbt:merge2">
        <xsl:with-param name="root1" select="$root1"/>
        <xsl:with-param name="comp"  select="$comp"/>
        <xsl:with-param name="comb"  select="$comb"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="(rbt:right,$rbt:empty_node)[1]"
                         mode="rbt:merge2">
      <xsl:with-param name="root1" as="element(rbt:left)">
        <xsl:apply-templates select="$prefix" mode="rbt:add_left">
          <xsl:with-param name="key"    select="rbt:key"/>
          <xsl:with-param name="comp"   select="$comp"/>
          <xsl:with-param name="data"   select="rbt:data/*"/>
          <xsl:with-param name="comb"   select="$comb"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="comp" select="$comp"/>
      <xsl:with-param name="comb" select="$comb"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="rbt:empty" mode="rbt:merge1">
    <xsl:param name="root2" as="element()"/> <!-- rbt:empty|rbt:left -->
    <xsl:sequence select="$root2"/>
  </xsl:template>

  <xsl:template match="rbt:left" mode="rbt:merge1"> <!-- Root -->
    <xsl:param name="root2" as="element()"/> <!--rbt:empty|rbt:left-->
    <xsl:param name="comp"  as="element()"/>
    <xsl:param name="comb"  as="element()"/>
    <xsl:choose>
      <xsl:when test="($root2/@size,0)[1] gt @size">
        <xsl:apply-templates select="$root2" mode="rbt:merge2">
          <xsl:with-param name="root1" select="current()"/>
          <xsl:with-param name="comp"  select="$comp"/>
          <xsl:with-param name="comb"  select="$comb"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="current()" mode="rbt:merge2">
          <xsl:with-param name="root1" select="$root2"/>
          <xsl:with-param name="comp"  select="$comp"/>
          <xsl:with-param name="comb"  select="$comb"/>
        </xsl:apply-templates>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:function name="rbt:merge" as="element(rbt:t)">
    <xsl:param name="tree1" as="element(rbt:t)"/>
    <xsl:param name="tree2" as="element(rbt:t)"/>
    <xsl:param name="comp"  as="element()"/>
    <xsl:param name="comb"  as="element()"/>
    <rbt:t>
      <xsl:apply-templates select="$tree1/element()" mode="rbt:merge1">
        <xsl:with-param name="root2" select="$tree2/element()"/>
        <xsl:with-param name="comp"  select="$comp"/>
        <xsl:with-param name="comb"  select="$comb"/>
      </xsl:apply-templates>
    </rbt:t>
  </xsl:function>

<!-- ==================================================================== -->
<!-- Dumping the data -->

  <!--
  In increasing order of the keys. This is simply a deep-first,
  left-to-right, traversal of the tree.
  -->

  <xsl:template match="rbt:empty" mode="rbt:incr"/>

  <xsl:template match="rbt:left|rbt:right" mode="rbt:incr">
    <xsl:apply-templates select="rbt:left" mode="rbt:incr"/>
    <xsl:sequence select="rbt:data/*"/>
    <xsl:apply-templates select="rbt:right" mode="rbt:incr"/>
  </xsl:template>

  <xsl:function name="rbt:incr" as="element()*">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:apply-templates select="$tree/element()" mode="rbt:incr"/>
  </xsl:function>

</xsl:transform>
