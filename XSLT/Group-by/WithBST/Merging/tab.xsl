<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:grp="file://group-by.xsl"
               xmlns:tab="file://tab.xsl"
               exclude-result-prefixes="xs grp tab">

  <xsl:import href="group-by.xsl"/>

  <xsl:output method="xhtml"
           doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
           doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
           indent="yes"/>

<!-- ====================================================================== -->
<!-- Main -->

  <xsl:template match="tab:keys_of" mode="callback">
    <xsl:param name="arg" as="element()"/>
    <xsl:sequence select="$arg/@country,$arg/@name"/>
  </xsl:template>

  <xsl:template match="/">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
		<title>Some cities</title>
	  </head>
	  <body>
        <table border="1">
		  <tr>
			<th>Rank</th>
            <th>Key</th>
			<th>@country</th>
            <th>@name</th>
			<th>Cities</th>
            <th>Countries</th>
			<th>Population</th>
		  </tr>
          <xsl:variable name="groups" as="element(grp:group)*">
            <xsl:call-template name="grp:group-by">
              <xsl:with-param name="pop"     select="cities/city"/>
              <xsl:with-param name="mk_keys" as="element(tab:keys_of)">
                <tab:keys_of/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:for-each select="$groups">
            <xsl:variable name="current-grouping-key" as="xs:string"
                          select="@key"/>
            <xsl:variable name="position" as="xs:integer"
                          select="position()"/>
            <xsl:variable name="current-group" as="item()*" select="*"/>
            <xsl:for-each select="*[1]">
              <tr>
                <td><xsl:value-of select="$position"/></td>
                <td><xsl:value-of select="$current-grouping-key"/></td>
                <td><xsl:value-of select="./@country"/></td>
                <td><xsl:value-of select="@name"/></td>
                <td>
                  <xsl:value-of select="$current-group/@name"
                                separator=", "/>
                </td>
                <td>
                  <xsl:value-of select="$current-group/@country"
                                separator=", "/>
                </td>
                <td><xsl:value-of select="sum($current-group/@pop)"/></td>
              </tr>
            </xsl:for-each>
          </xsl:for-each>
        </table>
	  </body>
	</html>
  </xsl:template>

</xsl:transform>
