<?xml version="1.0" encoding="iso-8859-1"?>

<!DOCTYPE xsl:transform [
  <!ELEMENT bst:t     (bst:empty | bst:node)>
  <!ELEMENT bst:empty EMPTY>
  <!ELEMENT bst:node  ((bst:empty | bst:node),bst:data,(bst:empty | bst:node))>
  <!ATTLIST bst:node  key ID #REQUIRED>
  <!ELEMENT bst:data  ANY>
]>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:bst="file://bst-ranked.xsl">

  <xsl:template match="bst:empty" mode="add">
    <xsl:param name="key" as="xs:string" tunnel="yes"/>
    <xsl:param name="data" as="item()*" tunnel="yes"/>
    <bst:node key="{$key}">
      <bst:empty/>
      <bst:data><xsl:sequence select="$data"/></bst:data>
      <bst:empty/>
    </bst:node>
  </xsl:template>

  <xsl:template match="bst:node" mode="add">
    <xsl:param name="key" as="xs:string" tunnel="yes"/>
    <xsl:param name="data" as="item()*" tunnel="yes"/>
    <xsl:copy>
      <xsl:sequence select="@key"/>
      <xsl:choose>
        <xsl:when test="$key lt @key">
          <xsl:apply-templates select="element()[1]" mode="#current"/>
          <xsl:sequence select="bst:data"/>
          <xsl:sequence select="element()[3]"/>
        </xsl:when>
        <xsl:when test="$key gt @key">
          <xsl:sequence select="element()[1]"/>
          <xsl:sequence select="bst:data"/>
          <xsl:apply-templates select="element()[3]" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="element()[1]"/>
          <bst:data>
            <xsl:sequence select="bst:data/node()"/>
            <xsl:sequence select="$data"/>
          </bst:data>
          <xsl:sequence select="element()[3]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
