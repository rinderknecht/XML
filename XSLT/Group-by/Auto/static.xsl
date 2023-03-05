<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:err="static.xsl">

  <xsl:function name="err:XTSE1080_1">
    <xsl:message terminate="yes">
      <xsl:text>[XTSE1080] Grouping attributes are mutually exclusive.</xsl:text>
    </xsl:message>
  </xsl:function>

  <xsl:function name="err:XTSE1080_2">
    <xsl:message terminate="yes">
      <xsl:text>[XTSE1080] One grouping attribute is mandatory.</xsl:text>
    </xsl:message>
  </xsl:function>

  <xsl:function name="err:XTSE0090">
    <xsl:param name="attr" as="xs:string"/>
    <xsl:param name="elem" as="xs:string"/>
    <xsl:message terminate="yes">
      <xsl:text>[XTSE0090] Attribute `$attr' is not allowed on element `$elem'.</xsl:text>
    </xsl:message>
  </xsl:function>

  <xsl:function name="err:XTSE1090">
    <xsl:message terminate="yes">
      <xsl:text>[XTSE1090] Attribute `collation' is only allowed with attribute `group-by' or `group-adjacent'.</xsl:text>
    </xsl:message>
  </xsl:function>

  <xsl:function name="err:mandatory_attribute">
    <xsl:param name="attr" as="xs:string"/>
    <xsl:param name="elem" as="xs:string"/>
    <xsl:message terminate="yes">
      <xsl:text>[XTSE010] Attribute `$attr' is mandatory in element `$elem'.</xsl:text>
    </xsl:message>
  </xsl:function>

</xsl:transform>
