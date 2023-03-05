<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:err="static.xsl">

  <xsl:import href="static.xsl"/>

  <xsl:template match="element()">
    <xsl:copy>
      <xsl:apply-templates select="@*,node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="attribute()|text()|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:if test="empty(*[2])">
      <xsl:sequence select="err:
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <xsl:template match="xsl:for-each-group">
    <xsl:variable name="grp_attr"
         select="@group-by|@group-adjacent|@group-starting-with|@group-ending-with"/>
    <xsl:variable name="other_attr"
         select="not(@group-by|@group-adjacent|@group-starting-with
                    |@group-ending-with|@collation)"/>
    <xsl:choose>
      <xsl:when test="@select">
        <xsl:choose>
          <xsl:when test="empty($grp_attr)">
            <xsl:sequence select="err:XTSE1080_2()"/>
          </xsl:when>
          <xsl:when test="empty($grp_attr[2])">
            <xsl:if test="@collation">
              <xsl:if test="$grp_attr ne 'group-by' and $grp_attr ne 'group-adjacent'">
                <xsl:sequence select="err:XTSE1090()"/>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="err:XTSE1080_1()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="err:mandatory_attribute('select',name())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
