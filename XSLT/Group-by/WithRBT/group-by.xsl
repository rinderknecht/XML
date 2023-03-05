<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:rbt="file://red-black.xsl"
               xmlns:hof="file://higher-order.xsl"
               xmlns:grp="file://group-by.xsl"
               exclude-result-prefixes="xs rbt hof grp">

  <xsl:import href="higher-order.xsl"/>
  <xsl:import href="red-black.xsl"/>

<!-- ===================================================================== -->

  <xsl:template match="grp:append" mode="hof:fun">
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:sequence select="$arg1,$arg2"/>
  </xsl:template>

  <xsl:function name="grp:append" as="element(grp:append)">
    <grp:append/>
  </xsl:function>

<!-- ===================================================================== -->
<!-- Three-way Comparisons -->

  <!-- Comparing strings -->

  <xsl:template match="grp:cmp_str" mode="hof:fun">
    <xsl:param name="arg1" as="xs:string"/>
    <xsl:param name="arg2" as="xs:string"/>
    <xsl:sequence select="xs:integer($arg2 lt $arg1)
                          - xs:integer($arg1 lt $arg2)"/>
  </xsl:template>

  <xsl:function name="grp:cmp_str" as="element(grp:cmp_str)">
    <grp:cmp_str/>
  </xsl:function>

  <!-- Lexicographic order on pairs of integers -->

  <xsl:template match="grp:lex_order" mode="hof:fun">
    <xsl:param name="arg1" as="element(grp:key)"/>
    <xsl:param name="arg2" as="element(grp:key)"/>
    <xsl:variable name="diff_pos" as="xs:integer"
                  select="xs:integer($arg1/@pos) - xs:integer($arg2/@pos)"/>
    <xsl:choose>
      <xsl:when test="$diff_pos eq 0">
        <xsl:sequence select="xs:integer($arg1/@key_pos)
                              - xs:integer($arg2/@key_pos)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$diff_pos"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="grp:lex_order" as="element(grp:lex_order)">
    <grp:lex_order/>
  </xsl:function>
  
<!-- ===================================================================== -->
<!-- Sorting by position -->

  <xsl:template match="rbt:empty" mode="grp:sort_by_pos">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:sequence select="$tree"/>
  </xsl:template>

  <xsl:template match="rbt:left|rbt:right" mode="grp:sort_by_pos">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:variable name="prefix" as="element(rbt:t)">
      <xsl:apply-templates select="(rbt:left,$rbt:empty_node)[1]"
                           mode="grp:sort_by_pos">
        <xsl:with-param name="tree" select="$tree" as="element(rbt:t)"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="buckets" as="element(grp:bucket)*"
                  select="rbt:data/grp:bucket"/>
    <xsl:variable name="group" as="element(grp:group)">
      <grp:group key="{rbt:key}">
        <xsl:sequence select="$buckets/*"/>
      </grp:group>
    </xsl:variable>
    <xsl:variable name="repr_key" as="element(grp:key)">
      <grp:key pos="{$buckets[1]/@pos}" key_pos="{$buckets[1]/@key_pos}"/>
    </xsl:variable>
    <xsl:apply-templates select="(rbt:right,$rbt:empty_node)[1]"
                         mode="grp:sort_by_pos">
      <xsl:with-param name="tree" as="element(rbt:t)"
                      select="rbt:insert($prefix,
                                         $repr_key,
                                         grp:lex_order(),
                                         $group,
                                         grp:append())"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:function name="grp:sort_by_pos" as="element(rbt:t)">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:apply-templates select="$tree/element()" mode="grp:sort_by_pos">
      <xsl:with-param name="tree" select="$rbt:empty_tree"
                      as="element(rbt:t)"/>
    </xsl:apply-templates>
  </xsl:function>

<!-- ===================================================================== -->
<!-- Sorting by key -->

  <xsl:template match="grp:first" mode="hof:fun">
    <xsl:param name="arg1" as="element()*"/>
    <xsl:param name="arg2" as="element()"/>
    <xsl:sequence select="$arg1,$arg2[@pos ne $arg1[last()]/@pos]"/>
  </xsl:template>

  <xsl:function name="grp:first" as="element(grp:first)">
    <grp:first/>
  </xsl:function>

  <xsl:function name="grp:insert_bucket" as="element(rbt:t)">
    <xsl:param name="tree"     as="element(rbt:t)"/>
    <xsl:param name="combine"  as="element()"/>
    <xsl:param name="item"     as="element()"/>
    <xsl:param name="item_pos" as="xs:integer"/>
    <xsl:param name="keys"     as="xs:string*"/>
    <xsl:param name="key_pos"  as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="empty($keys)">
        <xsl:sequence select="$tree"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="bucket" as="element(grp:bucket)">
          <grp:bucket pos="{$item_pos}" key_pos="{$key_pos}">
            <xsl:sequence select="$item"/>
          </grp:bucket>
        </xsl:variable>
        <xsl:variable name="new_tree" as="element(rbt:t)"
                      select="rbt:insert($tree,
                                         $keys[1],
                                         grp:cmp_str(),
                                         $bucket,
                                         $combine)"/>
        <xsl:sequence select="grp:insert_bucket($new_tree,
                                                $combine,
                                                $item,
                                                $item_pos,
                                                $keys[position()>1],
                                                $key_pos + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="grp:sort_by_key" as="element(rbt:t)">
    <xsl:param name="population" as="item()*"/>
    <xsl:param name="keys_of"    as="element()"/>
    <xsl:param name="tree"       as="element(rbt:t)"/>
    <xsl:param name="position"   as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="empty($population)">
        <xsl:sequence select="$tree"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="keys" as="xs:string*"
                      select="hof:apply($keys_of,$population[1])"/>
        <xsl:variable name="new_tree" as="element(rbt:t)"
                      select="grp:insert_bucket($tree,
                                                grp:first(),
                                                $population[1],
                                                $position,
                                                $keys,
                                                1)"/>
        <xsl:sequence
             select="grp:sort_by_key($population[position()>1],
                                     $keys_of,
                                     $new_tree,
                                     $position+1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function> 

<!-- ===================================================================== -->
<!-- Grouping -->

  <xsl:function name="grp:group-by" as="element(rbt:t)">
    <xsl:param name="population" as="element()*"/>
    <xsl:param name="keys_of" as="element()"/>
    <xsl:sequence select="grp:sort_by_pos( 
                            grp:sort_by_key($population,
                                            $keys_of,
                                            $rbt:empty_tree,
                                            1))"/>
  </xsl:function>

  <xsl:function name="grp:groups_of" as="element(grp:group)*">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:sequence select="rbt:incr($tree)"/>
  </xsl:function>

</xsl:transform>
