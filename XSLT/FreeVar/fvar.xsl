<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fv="file://fvar.xsl">

  <xsl:output method="xhtml"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"
            omit-xml-declaration="yes"/>

 <xsl:template match="xsl:transform">
   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
     <head>
       <title>Free Variables</title>
     </head>
     <body>
       <h2>Free Variables</h2>
       <ol>
         <xsl:call-template name="fv:variables">
           <xsl:with-param name="env" select="()"/>
           <xsl:with-param name="vars" select="xsl:variable"/>
         </xsl:call-template>
       </ol>
     </body>
   </html>
 </xsl:template>

  <xsl:template name="fv:variables">
    <xsl:param name="env"  as="element()*"/>
    <xsl:param name="vars" as="element(xsl:variable)*"/>
    <xsl:choose>
      <xsl:when test="empty($vars)">
        <xsl:sequence select="$env"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="fv:variables">
          <xsl:with-param name="env" as="element()*">
            <xsl:call-template name="fv:variable">
              <xsl:with-param name="env" select="$env"/>
              <xsl:with-param name="var" select="element(xsl:variable)"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="vars" select="$vars[position()>1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fv:variable">
    <xsl:param name="env" as="element()*"/>
    <xsl:param name="var" as="element(xsl:variable)"/>
    
  </xsl:template>

</xsl:transform>
