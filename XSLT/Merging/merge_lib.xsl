<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:mrg="file://merge_lib.xsl">

  <xsl:template name="mrg:merge">
    <xsl:param name="fst" as="item()*"/>
    <xsl:param name="snd" as="item()*"/>
    <xsl:param name="lt"  as="element()"/>
    <xsl:choose>
      <xsl:when test="empty($fst)">
        <xsl:sequence select="$snd"/>
      </xsl:when>
      <xsl:when test="empty($snd)">
        <xsl:sequence select="$fst"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="lt_cmp" as="xs:boolean">
          <xsl:apply-templates select="$lt" mode="callback">
            <xsl:with-param name="arg1" select="$fst[1]"/>
            <xsl:with-param name="arg2" select="$snd[1]"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$lt_cmp">
            <xsl:sequence select="$fst[1]"/>
            <xsl:call-template name="mrg:merge">
              <xsl:with-param name="fst" select="$fst[position()>1]"/>
              <xsl:with-param name="snd" select="$snd"/>
              <xsl:with-param name="lt" select="$lt"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$snd[1]"/>
            <xsl:call-template name="mrg:merge">
              <xsl:with-param name="fst" select="$fst"/>
              <xsl:with-param name="snd" select="$snd[position()>1]"/>
              <xsl:with-param name="lt" select="$lt"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
