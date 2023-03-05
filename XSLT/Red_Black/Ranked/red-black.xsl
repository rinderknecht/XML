<?xml version="1.0" encoding="iso-8859-1"?>

<!DOCTYPE xsl:transform [
  <!ELEMENT rbt:t     (rbt:empty | rbt:node)>
  <!ELEMENT rbt:empty EMPTY>
  <!ELEMENT rbt:node  ((rbt:empty|rbt:node),rbt:data,(rbt:empty|rbt:node))>
  <!ATTLIST rbt:node  colour (red | black) #REQUIRED
                      key    ID            #REQUIRED>
  <!ELEMENT rbt:data  ANY>
]>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:rbt="file://red-black-ranked.xsl">

<!-- ====================================================================== -->
<!-- The empty tree and the empty node -->

  <xsl:variable name="rbt:empty_tree" as="element(rbt:t)">
    <rbt:t><rbt:empty/></rbt:t>
  </xsl:variable>

  <xsl:variable name="rbt:empty_node" as="element(rbt:empty)">
    <rbt:empty/>
  </xsl:variable>

<!-- ====================================================================== -->
<!-- Balancing the tree -->

  <xsl:template match="rbt:node[@colour eq 'black'][child::element()[1][self::rbt:node][@colour eq 'red'][child::element()[1][self::rbt:node][@colour eq 'red']]]" mode="rbt:balance">
    <rbt:node colour="red" key="{element()[1]/@key}">
      <rbt:node colour="black" key="{element()[1]/element()[1]/@key}">
        <xsl:sequence select="element()[1]/element()[1]/element()[1]"/>
        <xsl:sequence select="element()[1]/element()[1]/rbt:data"/>
        <xsl:sequence select="element()[1]/element()[1]/element()[3]"/>
      </rbt:node>
      <xsl:sequence select="element()[1]/rbt:data"/>
      <xsl:copy>
        <xsl:sequence select="(@colour,@key)"/>
        <xsl:sequence select="element()[1]/element()[3]"/>
        <xsl:sequence select="rbt:data"/>
        <xsl:sequence select="element()[3]"/>
      </xsl:copy>
    </rbt:node>
  </xsl:template>

  <xsl:template match="rbt:node[@colour eq 'black'][child::element()[1][self::rbt:node][@colour eq 'red'][child::element()[3][self::rbt:node][@colour eq 'red']]]" mode="rbt:balance">
    <rbt:node colour="red" key="{element()[1]/element()[3]/@key}">
      <rbt:node colour="black" key="{element()[1]/@key}">
        <xsl:sequence select="element()[1]/element()[1]"/>
        <xsl:sequence select="element()[1]/rbt:data"/>
        <xsl:sequence select="element()[1]/element()[3]/element()[1]"/>
      </rbt:node>
      <xsl:sequence select="element()[1]/element()[3]/rbt:data"/>
      <xsl:copy>
        <xsl:sequence select="(@colour,@key)"/>
        <xsl:sequence select="element()[1]/element()[3]/element()[3]"/>
        <xsl:sequence select="rbt:data"/>
        <xsl:sequence select="element()[3]"/>
      </xsl:copy>
    </rbt:node>
  </xsl:template>

  <xsl:template match="rbt:node[@colour eq 'black'][child::element()[3][self::rbt:node][@colour eq 'red'][child::element()[1][self::rbt:node][@colour eq 'red']]]" mode="rbt:balance">
    <rbt:node colour="red" key="{element()[3]/element()[1]/@key}">
      <xsl:copy>
        <xsl:sequence select="(@colour,@key)"/>
        <xsl:sequence select="element()[1]"/>
        <xsl:sequence select="rbt:data"/>
        <xsl:sequence select="element()[3]/element()[1]/element()[1]"/>
      </xsl:copy>
      <xsl:sequence select="element()[3]/element()[1]/rbt:data"/>
      <rbt:node colour="black" key="{element()[3]/@key}">
        <xsl:sequence select="element()[3]/element()[1]/element()[3]"/>
        <xsl:sequence select="element()[3]/rbt:data"/>
        <xsl:sequence select="element()[3]/element()[3]"/>
      </rbt:node>
    </rbt:node>
  </xsl:template>
  
  <xsl:template match="rbt:node[@colour eq 'black'][child::element()[3][self::rbt:node][@colour eq 'red'][child::element()[3][self::rbt:node][@colour eq 'red']]]" mode="rbt:balance">
    <rbt:node colour="red" key="{element()[3]/@key}">
      <xsl:copy>
        <xsl:sequence select="(@colour,@key)"/>
        <xsl:sequence select="element()[1]"/>
        <xsl:sequence select="rbt:data"/>
        <xsl:sequence select="element()[3]/element()[1]"/>
      </xsl:copy>
      <xsl:sequence select="element()[3]/rbt:data"/>
      <rbt:node colour="black" key="{element()[3]/element()[3]/@key}">
        <xsl:sequence select="element()[3]/element()[3]/element()[1]"/>
        <xsl:sequence select="element()[3]/element()[3]/rbt:data"/>
        <xsl:sequence select="element()[3]/element()[3]/element()[3]"/>
      </rbt:node>
    </rbt:node>
  </xsl:template>

  <xsl:template match="rbt:*" mode="rbt:balance">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="rbt:empty" mode="rbt:add">
    <xsl:param name="key" as="xs:string" tunnel="yes"/>
    <xsl:param name="data" as="item()*" tunnel="yes"/>
    <rbt:node colour="red" key="{$key}">
      <rbt:empty/>
      <rbt:data><xsl:sequence select="$data"/></rbt:data>
      <rbt:empty/>
    </rbt:node>
  </xsl:template>

  <xsl:template match="rbt:node" mode="rbt:add">
    <xsl:param name="key" as="xs:string" tunnel="yes"/>
    <xsl:param name="data" as="item()*" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$key lt @key">
        <xsl:variable name="new_node" as="element(rbt:node)">
          <xsl:copy>
            <xsl:sequence select="(@colour,@key)"/>
            <xsl:apply-templates select="element()[1]" mode="#current"/>
            <xsl:sequence select="rbt:data"/>
            <xsl:sequence select="element()[3]"/>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$new_node" mode="rbt:balance"/>
      </xsl:when>
      <xsl:when test="$key gt @key">
        <xsl:variable name="new_node" as="element(rbt:node)">
          <xsl:copy>
            <xsl:sequence select="(@colour,@key)"/>
            <xsl:sequence select="element()[1]"/>
            <xsl:sequence select="rbt:data"/>
            <xsl:apply-templates select="element()[3]" mode="#current"/>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$new_node" mode="rbt:balance"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:sequence select="(@colour,@key)"/>
          <xsl:sequence select="element()[1]"/>
          <rbt:data>
            <xsl:sequence select="rbt:data/node()"/>
            <xsl:sequence select="$data"/>
          </rbt:data>
          <xsl:sequence select="element()[3]"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="rbt:insert" as="element(rbt:t)">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="data" as="item()*"/>
    <xsl:variable name="node" as="element(rbt:node)">
      <xsl:apply-templates select="$tree/element()" mode="rbt:add">
        <xsl:with-param name="key" select="$key" tunnel="yes"/>
        <xsl:with-param name="data" select="$data" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <rbt:t>
      <rbt:node colour="black" key="{$node/@key}">
        <xsl:sequence select="$node/element()"/>
      </rbt:node>
    </rbt:t>
  </xsl:function>

<!-- ====================================================================== -->

  <xsl:template match="rbt:empty" mode="rbt:seq_of"/>

  <xsl:template match="rbt:node" mode="rbt:seq_of">
    <xsl:apply-templates select="element()[1]" mode="rbt:seq_of"/>
    <xsl:sequence select="current()"/>
    <xsl:apply-templates select="element()[3]" mode="rbt:seq_of"/>
  </xsl:template>

  <xsl:function name="rbt:seq_of" as="element(rbt:node)*">
    <xsl:param name="tree" as="element(rbt:t)"/>
    <xsl:apply-templates select="$tree/element()" mode="rbt:seq_of"/>
  </xsl:function>

</xsl:transform>
