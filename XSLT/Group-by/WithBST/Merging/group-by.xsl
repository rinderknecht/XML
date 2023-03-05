<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:bst="file://bst.xsl"
               xmlns:mrg="file://merge_lib.xsl"
               xmlns:grp="file://group-by.xsl"
               exclude-result-prefixes="xs bst mrg grp">

  <xsl:import href="bst.xsl"/>
  <xsl:import href="merge_lib.xsl"/>

<!-- ===================================================================== -->
<!-- Three-way Comparisons (calls back) -->

  <!-- Comparing strings (three-way) -->

  <xsl:template match="grp:cmp_str" mode="callback">
    <xsl:param name="arg1" as="xs:string"/>
    <xsl:param name="arg2" as="xs:string"/>
    <xsl:sequence select="xs:integer($arg2 lt $arg1)
                          - xs:integer($arg1 lt $arg2)"/>
  </xsl:template>

  <!-- Comparing groups by population order -->

  <xsl:template match="grp:ord_lt" mode="callback">
    <xsl:param name="arg1" as="element(grp:group)"/>
    <xsl:param name="arg2" as="element(grp:group)"/>
    <xsl:sequence select="xs:integer($arg1/@order) 
                          lt xs:integer($arg2/@order)"/>
  </xsl:template>

<!-- ===================================================================== -->
<!-- Merging branches bottom-up (tree heap semantics) -->

  <xsl:template name="grp:fuse">
    <xsl:param name="rev" as="element()*"/>
    <xsl:param name="top" as="element(grp:group)"/>
    <xsl:param name="grp" as="element(grp:group)*"/>
    <xsl:choose>
      <xsl:when test="empty($grp)">
        <xsl:sequence select="$top/(@order,*),$rev"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grp:fuse">
          <xsl:with-param name="rev" select="$top/*,$rev"/>
          <xsl:with-param name="top" select="$grp[1]"/>
          <xsl:with-param name="grp" select="$grp[position()>1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="bst:empty" mode="grp:sort_by_order"/>

  <xsl:template match="bst:left|bst:right" mode="grp:sort_by_order">
    <xsl:variable name="groups" as="element(grp:group)*"
                  select="bst:data/grp:group"/>
    <grp:group key="{bst:key}">
      <xsl:call-template name="grp:fuse">
        <xsl:with-param name="rev" select="()"/>
        <xsl:with-param name="top" select="$groups[1]"/>
        <xsl:with-param name="grp" select="$groups[position()>1]"/>
      </xsl:call-template>
    </grp:group>
    <xsl:call-template name="mrg:merge">
      <xsl:with-param name="fst" as="element(grp:group)*">
        <xsl:apply-templates select="bst:left" mode="grp:sort_by_order"/>
      </xsl:with-param>
      <xsl:with-param name="snd" as="element(grp:group)*">
        <xsl:apply-templates select="bst:right" mode="grp:sort_by_order"/>
      </xsl:with-param>
      <xsl:with-param name="lt" as="element(grp:ord_lt)">
        <grp:ord_lt/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="grp:sort_by_order" as="element(grp:group)*">
    <xsl:param name="tree" as="element()"/>
    <xsl:apply-templates select="$tree" mode="grp:sort_by_order"/>
  </xsl:template>

<!-- ===================================================================== -->
<!-- Grouping items according to their keys and ordering the groups
     according to the keys of their initial item.
 -->

  <!--
    
  -->

  <xsl:template match="grp:push" mode="callback">
    <xsl:param name="arg1" as="element()*"/>
    <xsl:param name="arg2" as="element()"/>
    <xsl:if test="number($arg2/@order) gt 1+$arg1[1]/@order">
      <xsl:sequence select="$arg2"/>
    </xsl:if> 
    <xsl:sequence select="$arg1"/>
  </xsl:template>

  <!--
    Named template `grp:insert' has three parameters: `item' is the
    item to be inserted in a group according to its keys; the
    parameter `keys' are the keys of parameter `item'; `ord_tree' is
    an accumulator consisting of a pair whose first component is the
    population order of the item in `pop' and the second a Binary
    Search Tree (BST) containing items already grouped according to
    their keys. The result of calling the template `grp:insert' is a
    new accumulator where the order has been added with the number of
    keys and the tree has be augmented with a new item (if it belongs
    to a new group, then a new node has been created, otherwise a
    group in an existing node has been extended to contain it).

    The template is recursive. If there are no keys, then the
    accumulator (`$ord_tree') is returned. Otherwise, a recursive call
    is made with the remaining keys (`$keys[position()>1]') and the
    new accumulator has its order incremented (`$ord_tree[1]+1') and
    its tree is added the item (`$item'). The item is added by means
    of the application of templates belonging to the namespace `bst'
    (notice the special mode `bst:add'). This application carries four
    parameters: `key' is the first key (`$keys[1]') of the item;
    `comp' is a callback to a three-way comparison on keys (__keys are
    strings__); `data' is the data to be added to the tree, here is a
    group containing the item with its order (as an attribute
    `grp:group/@order'); `comb' is a callback used when a key is
    already used by a node in the tree: it decides what to do with the
    data to be added and the current contents of the node (here, the
    data will be pushed on top of the current groups in the node).

    The nodes of the resulting tree (just as the nodes of the input
    tree in the accumulator `$ord_tree') contain sequences of groups,
    each containing exactly __one__ item, and the item with smallest
    population order is last in the sequence (due to the push
    strategy).
  -->

  <xsl:template name="grp:insert" as="item()*">
    <xsl:param name="ord_tree" as="item()*"/>
    <xsl:param name="item"     as="item()"/>
    <xsl:param name="keys"     as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="empty($keys)">
        <xsl:sequence select="$ord_tree"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grp:insert">
          <xsl:with-param name="ord_tree" as="item()*">
            <xsl:sequence select="$ord_tree[1] + 1"/>
            <xsl:apply-templates select="$ord_tree[2]" mode="bst:add">
              <xsl:with-param name="key"  select="$keys[1]"/>
              <xsl:with-param name="comp" as="element(grp:cmp_str)">
                <grp:cmp_str/>
              </xsl:with-param>
              <xsl:with-param name="data" as="element(grp:group)">
                <grp:group order="{$ord_tree[1]}">
                  <xsl:sequence select="$item"/>
                </grp:group>
              </xsl:with-param>
              <xsl:with-param name="comb" as="element(grp:push)">
                <grp:push/>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:with-param>
          <xsl:with-param name="item" select="$item"/>
          <xsl:with-param name="keys" select="$keys[position()>1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Named template `grp:sort_by_key' has three parameters: `pop',
    which is the population; `mk_keys', which is the callback
    computing the keys for the items in the population; `ord_tree',
    which is an accumulator consisting of a pair whose first component
    is the population order of the first item in `pop' and the second
    a Binary Search Tree (BST) containing items already grouped
    according to their keys.

    The template is recurvise. If the population is empty, then the
    BST is returned (`$ord_tree[2]'), as it is supposed to contain the
    groups up to now (ordered by their initial item). Otherwise, the
    named template `grp:insert' is called to insert the first item in
    the population (`$pop[1]') into the BST of the accumulator, and
    then a recursive call is made with the rest of the population
    (`$pop[position()>1]') and the new accumulator resulting from the
    call to `grp:insert'. In other words: items are inserted one by
    one into groups ordered by their keys.

    The call to `grp:insert' takes the keys of the item to be inserted
    (parameter `keys'). These keys are computed by the callback
    `$mk_keys', i.e., templates are applied to it with the item as
    argument (see parameter `arg').

    The result of template `grp:sort_by_key' is the BST obtained by
    adding to the input BST (`$ord_tree[2]') the items in the given
    population (`$pop'), whose keys are generated by applying a
    template to `$mk_keys'.
  -->

  <xsl:template name="grp:sort_by_key" as="element()*">
    <xsl:param name="pop"      as="item()*"/>
    <xsl:param name="mk_keys"  as="element()"/>
    <xsl:param name="ord_tree" as="item()*"/>
    <xsl:choose>
      <xsl:when test="empty($pop)">
        <xsl:sequence select="$ord_tree[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grp:sort_by_key">
          <xsl:with-param name="pop"      select="$pop[position()>1]"/>
          <xsl:with-param name="mk_keys"  select="$mk_keys"/>
          <xsl:with-param name="ord_tree" as="item()*">
            <xsl:call-template name="grp:insert">
              <xsl:with-param name="ord_tree" select="$ord_tree"/>
              <xsl:with-param name="item"     select="$pop[1]"/>
              <xsl:with-param name="keys"     as="item()*">
                <xsl:apply-templates select="$mk_keys" mode="callback">
                  <xsl:with-param name="arg" select="$pop[1]"/>
                </xsl:apply-templates>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 


<!-- ===================================================================== -->
<!-- 
  Grouping items according to their keys and ordering the groups
  according to the population order of their initial item.

  Named template `grp:group-by' has two parameters: `pop' and
  `mk_keys'. Parameter `pop' is the population (a sequence of items)
  to be divided into groups according to the keys the items in it
  produce by means of `mk_keys' (which is a call-back).

  The first phase consists in sorting the population according to the
  keys, so two items with the same key belong to the same
  group. Moreover, each group is tagged by the order in the population
  of the initial item in the group, that is, the item within the group
  that is first in population order. An item with different keys is in
  different groups.

  The second phase consists in sorting the result of the first phase
  according to the population order.

  The result is a sequence of groups, so that all items in a group
  have the same key and the groups have increasing population order of
  their initial item.
 
  The first phase is implemented by a call to the named template
  `grp:sort_by_key' and the second one by calling the named template
  `grp:sort_by_order'.
-->

  <xsl:template name="grp:group-by" as="element(grp:group)*">
    <xsl:param name="pop"     as="element()*"/>
    <xsl:param name="mk_keys" as="element()"/>
    <xsl:call-template name="grp:sort_by_order">
      <xsl:with-param name="tree" as="element()">
        <xsl:call-template name="grp:sort_by_key">
          <xsl:with-param name="pop"      select="$pop"/>
          <xsl:with-param name="mk_keys"  select="$mk_keys"/>
          <xsl:with-param name="ord_tree" select="1,$bst:empty"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
