<?xml version="1.0" encoding="iso-8859-1"?>

<!-- The non-empty tree has root bst:left -->

<!DOCTYPE xsl:transform [
  <!ELEMENT bst:empty EMPTY>
  <!ELEMENT bst:left  (bst:key,bst:data,(bst:left)?,(bst:right)?)>
  <!ELEMENT bst:right (bst:key,bst:data,(bst:left)?,(bst:right)?)>
  <!ELEMENT bst:key   ANY>
  <!ELEMENT bst:data  ANY>
]>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:bst="file://bst.xsl"
               exclude-result-prefixes="xs bst">

<!-- ==================================================================== -->
<!-- The empty tree/node -->

  <xsl:variable name="bst:empty" as="element(bst:empty)">
    <bst:empty/>
  </xsl:variable>

<!-- ==================================================================== -->
<!-- Inserting a node
-->

  <!--
  -->

  <xsl:template match="bst:empty" mode="bst:add_top">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>

    <bst:left>
      <bst:key><xsl:sequence select="$key"/></bst:key>
      <bst:data><xsl:sequence select="$data"/></bst:data>
    </bst:left>
  </xsl:template>

  <xsl:template match="bst:left" mode="bst:add_top">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="lt"   as="element()"/>
    <xsl:param name="eq"   as="element()"/>
    <xsl:param name="comb" as="element()"/>
    
    <xsl:apply-templates select="." mode="bst:add_left">
      <xsl:with-param name="key"  select="$key"/>
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="lt"   select="$lt"/>
      <xsl:with-param name="eq"   select="$eq"/>
      <xsl:with-param name="comb" select="$comb"/>
      <xsl:with-param name="cand" select="bst:key"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!--
  -->

  <xsl:template match="bst:empty" mode="bst:add_left">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="eq"   as="element()"/>
    <xsl:param name="cand" as="item()"/>

    <xsl:variable name="eq_cmp" as="xs:boolean">
      <xsl:apply-templates select="$eq" mode="callback">
        <xsl:with-param name="arg1" as="item()" select="$key"/>
        <xsl:with-param name="arg2" as="item()" select="$cand"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$eq_cmp eq true()">
        <xsl:sequence select="$bst:empty"/>
      </xsl:when>
      <xsl:otherwise>
        <bst:left>
          <bst:key><xsl:sequence select="$key"/></bst:key>
          <bst:data><xsl:sequence select="$data"/></bst:data>
        </bst:left>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="bst:empty" mode="bst:add_right">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="eq"   as="element()"/>
    <xsl:param name="cand" as="item()"/>

    <xsl:variable name="eq_cmp" as="xs:boolean">
      <xsl:apply-templates select="$eq" mode="callback">
        <xsl:with-param name="arg1" as="item()" select="$key"/>
        <xsl:with-param name="arg2" as="item()" select="$cand"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$eq_cmp eq true()">
        <xsl:sequence select="$bst:empty"/>
      </xsl:when>
      <xsl:otherwise>
        <bst:right>
          <bst:key><xsl:sequence select="$key"/></bst:key>
          <bst:data><xsl:sequence select="$data"/></bst:data>
        </bst:right>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  This template inserts the piece of data $data with key $key in the
  tree whose root is matched by the pattern (note that the root of the
  whole tree is arbitrarily a bst:left element). The comparison
  between keys is specified by $lt, which corresponds to "lower than"
  and whose application leads to a boolean (it is a two-way
  comparison). When reaching an external node, the $key has to be
  compared for equality with the candidate 


  Notice how an empty node is used when creating the leaf (insertion
  is done at the leaves). We use the global variable $bst:empty to
  avoid recreating an empty node at each insertion. When two keys are
  equal, what should be done with the data in the node and the data to
  be inserted? This is specified by argument $comb (`combine'). For
  example, both informations could be stored in the existing node, in
  a certain order, or the new one could be discarded etc. depending on
  the caller's need.
  -->

  <xsl:template match="bst:left|bst:right" mode="bst:add_left bst:add_right">
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="lt"   as="element()"/>
    <xsl:param name="eq"   as="item()"/>
    <xsl:param name="comb" as="element()"/>
    <xsl:param name="cand" as="item()"/>

    <xsl:variable name="lt_cmp" as="xs:boolean">
      <xsl:apply-templates select="$lt" mode="callback">
        <xsl:with-param name="arg1" as="item()" select="$key"/>
        <xsl:with-param name="arg2" as="item()" select="bst:key"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$lt_cmp eq true()">
          <xsl:sequence select="bst:key,bst:data"/>
          <xsl:apply-templates select="(bst:left,$bst:empty)[1]"
                               mode="bst:add_left">
            <xsl:with-param name="key"  select="$key"/>
            <xsl:with-param name="data" select="$data"/>
            <xsl:with-param name="lt"   select="$lt"/>
            <xsl:with-param name="eq"   select="$eq"/>
            <xsl:with-param name="comb" select="$comb"/>
            <xsl:with-param name="cand" select="$cand"/>
          </xsl:apply-templates>
          <xsl:sequence select="bst:right"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="bst:key,bst:data,bst:left"/>
          <xsl:apply-templates select="(bst:right,$bst:empty)[1]"
                               mode="bst:add_right">
            <xsl:with-param name="key"  select="$key"/>
            <xsl:with-param name="data" select="$data"/>
            <xsl:with-param name="lt"   select="$lt"/>
            <xsl:with-param name="eq"   select="$eq"/>
            <xsl:with-param name="comb" select="$comb"/>
            <xsl:with-param name="cand" select="bst:key"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
  This is the wrapper around the templates above.
  -->

  <xsl:template name="bst:insert" as="element(bst:t)">
    <xsl:param name="tree" as="element(bst:t)"/>
    <xsl:param name="key"  as="item()"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:param name="lt"   as="element()"/>
    <xsl:param name="eq"   as="element()"/>
    <xsl:param name="comb" as="element()"/>
    <xsl:apply-templates select="$tree" mode="bst:add_top">
      <xsl:with-param name="key"  select="$key"/>
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="lt"   select="$lt"/>
      <xsl:with-param name="eq"   select="$eq"/>
      <xsl:with-param name="comb" select="$comb"/>
    </xsl:apply-templates>
  </xsl:template>

<!-- ==================================================================== -->
<!-- Inorder traversal -->

  <!-- Not in tail form -->

  <xsl:template match="bst:empty" mode="bst:inorder_ntc"/>

  <xsl:template match="bst:left|bst:right" mode="bst:inorder_ntc">
    <xsl:apply-templates select="bst:left" mode="bst:inorder_ntc"/>
    <xsl:sequence select="bst:data/*"/>
    <xsl:apply-templates select="bst:right" mode="bst:inorder_ntc"/>
  </xsl:template>

  <!-- In tail form -->

  <xsl:template name="bst:inorder">
    <xsl:param name="nodes"  as="element()*"/>
    <xsl:param name="forest" as="element()*"/>
    <xsl:choose>
      <xsl:when test="empty($forest)">
        <xsl:sequence select="$nodes"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$forest[1]" mode="bst:inorder">
          <xsl:with-param name="nodes"  select="$nodes"/>
          <xsl:with-param name="forest" select="$forest[position()>1]"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="bst:data" mode="bst:inorder">
    <xsl:param name="nodes"  as="element()*"/>
    <xsl:param name="forest" as="element()*"/>
    <xsl:call-template name="bst:inorder">
      <xsl:with-param name="nodes"  select="(*,$nodes)"/>
      <xsl:with-param name="forest" select="$forest"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="bst:left|bst:right" mode="bst:inorder">
    <xsl:param name="nodes"  as="element()*"/>
    <xsl:param name="forest" as="element()*"/>
    <xsl:call-template name="bst:inorder">
      <xsl:with-param name="nodes"  select="$nodes"/>
      <xsl:with-param name="forest"
                      select="(bst:right,bst:data,bst:left,$forest)"/>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
