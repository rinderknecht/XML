<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:hof="file://higher-order.xsl"
               exclude-result-prefixes="xs hof">

<!-- Higher-Order Functions a la Dimitre Novatchev (http://fxsl.sf.net) -->

<!-- ===================================================================== -->
<!-- Apply a function to its arguments -->

  <xsl:function name="hof:apply">
    <xsl:param name="fun" as="element()"/>
    <xsl:param name="arg"/>
    
    <xsl:apply-templates select="$fun" mode="hof:fun">
      <xsl:with-param name="arg" select="$arg"/>
    </xsl:apply-templates>
  </xsl:function>

  <xsl:function name="hof:apply">
    <xsl:param name="fun" as="element()"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    
    <xsl:apply-templates select="$fun" mode="hof:fun">
      <xsl:with-param name="arg1" select="$arg1"/>
      <xsl:with-param name="arg2" select="$arg2"/>
    </xsl:apply-templates>
  </xsl:function>

<!-- ===================================================================== -->
<!-- Folding -->

  <xsl:function name="hof:foldl">
    <xsl:param name="fun" as="element()"/>
    <xsl:param name="acc" as="item()*"/>
    <xsl:param name="list" as="item()*"/>
    <xsl:sequence
        select="if   (empty($list))
                then $acc
                else hof:foldl($fun,
                               hof:apply($fun,$acc,$list[1]),
                               $list[position()>1])"/>
  </xsl:function>

</xsl:transform>
