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

  <!-- Comparing strings -->

  <xsl:template match="grp:lt_str" mode="callback">
    <xsl:param name="arg1" as="xs:string"/>
    <xsl:param name="arg2" as="xs:string"/>
    <xsl:sequence select="$arg1 lt $arg2"/>
  </xsl:template>

  <xsl:template match="grp:eq_str" mode="callback">
    <xsl:param name="arg1" as="xs:string"/>
    <xsl:param name="arg2" as="xs:string"/>
    <xsl:sequence select="$arg1 eq $arg2"/>
  </xsl:template>

  <xsl:template match="grp:cmp_str" mode="callback">
    <xsl:param name="arg1" as="xs:string"/>
    <xsl:param name="arg2" as="xs:string"/>
    <xsl:sequence select="xs:integer($arg2 lt $arg1)
                          - xs:integer($arg1 lt $arg2)"/>
  </xsl:template>

  <!-- Comparing groups by index -->

  <xsl:template match="grp:lt_idx" mode="callback">
    <xsl:param name="arg1" as="element(grp:group)"/>
    <xsl:param name="arg2" as="element(grp:group)"/>
    <xsl:sequence select="xs:integer($arg1/@index) 
                          lt xs:integer($arg2/@index)"/>
  </xsl:template>

<!-- ===================================================================== -->
<!-- Merging branches bottom-up (tree heap semantics) -->

  <xsl:template name="grp:fuse">
    <xsl:param name="rev" as="element()*"/>
    <xsl:param name="top" as="element(grp:group)"/>
    <xsl:param name="grp" as="element(grp:group)*"/>
    <xsl:choose>
      <xsl:when test="empty($grp)">
        <xsl:sequence select="$top/(@index,*),$rev"/>
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

  <xsl:template match="bst:empty" mode="grp:merge_by_pos"/>

  <xsl:template match="bst:left|bst:right" mode="grp:merge_by_pos">
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
        <xsl:apply-templates select="bst:left" mode="grp:merge_by_pos"/>
      </xsl:with-param>
      <xsl:with-param name="snd" as="element(grp:group)*">
        <xsl:apply-templates select="bst:right" mode="grp:merge_by_pos"/>
      </xsl:with-param>
      <xsl:with-param name="lt" as="element(grp:lt_idx)">
        <grp:lt_idx/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="grp:merge_by_pos" as="element(grp:group)*">
    <xsl:param name="tree" as="element()"/>
    <xsl:apply-templates select="$tree" mode="grp:merge_by_pos"/>
  </xsl:template>

<!-- ===================================================================== -->
<!-- Sorting by key -->

  <xsl:template match="grp:push" mode="callback">
    <xsl:param name="arg1" as="element()*"/>
    <xsl:param name="arg2" as="element()"/>
    <xsl:sequence
        select="$arg2[number(@index) gt 1+$arg1[1]/@index],$arg1"/>
  </xsl:template>

  <xsl:template name="grp:insert" as="item()*">
    <xsl:param name="idx_tree" as="item()*"/>
    <xsl:param name="item"     as="item()"/>
    <xsl:param name="comb"     as="element()"/>
    <xsl:param name="keys"     as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="empty($keys)">
        <xsl:sequence select="$idx_tree"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grp:insert">
          <xsl:with-param name="idx_tree" as="item()*">
            <xsl:sequence select="$idx_tree[1] + 1"/>
            <xsl:apply-templates select="$idx_tree[2]" mode="bst:add_top">
              <xsl:with-param name="key"  select="$keys[1]"/>
              <xsl:with-param name="data" as="element(grp:group)">
                <grp:group index="{$idx_tree[1]}">
                  <xsl:sequence select="$item"/>
                </grp:group>
              </xsl:with-param>
              <xsl:with-param name="lt" as="element(grp:lt_str)">
                <grp:lt_str/>
              </xsl:with-param>
              <xsl:with-param name="eq" as="element(grp:eq_str)">
                <grp:eq_str/>
              </xsl:with-param>
              <xsl:with-param name="comb" select="$comb"/>
            </xsl:apply-templates>
          </xsl:with-param>
          <xsl:with-param name="item"  select="$item"/>
          <xsl:with-param name="comb"  select="$comb"/>
          <xsl:with-param name="keys"  select="$keys[position()>1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="grp:sort" as="element()*">
    <xsl:param name="pop"      as="item()*"/>
    <xsl:param name="mk_keys"  as="element()"/>
    <xsl:param name="idx_tree" as="item()*"/>
    <xsl:choose>
      <xsl:when test="empty($pop)">
        <xsl:sequence select="$idx_tree[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grp:sort">
          <xsl:with-param name="pop"      select="$pop[position()>1]"/>
          <xsl:with-param name="mk_keys"  select="$mk_keys"/>
          <xsl:with-param name="idx_tree" as="item()*">
            <xsl:call-template name="grp:insert">
              <xsl:with-param name="idx_tree" select="$idx_tree"/>
              <xsl:with-param name="item"     select="$pop[1]"/>
              <xsl:with-param name="comb"     as="element(grp:push)">
                <grp:push/>
              </xsl:with-param>
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
<!-- Grouping by keys -->

  <xsl:template name="grp:group-by" as="element(grp:group)*">
    <xsl:param name="pop"     as="element()*"/>
    <xsl:param name="mk_keys" as="element()"/>
    <xsl:call-template name="grp:merge_by_pos">
      <xsl:with-param name="tree" as="element()">
        <xsl:call-template name="grp:sort">
          <xsl:with-param name="pop"      select="$pop"/>
          <xsl:with-param name="mk_keys"  select="$mk_keys"/>
          <xsl:with-param name="idx_tree" select="1,$bst:empty"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
