<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xhtml"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
             doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
			  indent="yes"/>

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
		  <xsl:for-each-group select="cities/city" group-by="@country,@name">
<!--            <xsl:sort select="current-grouping-key()"/> -->
			<tr>
			  <td><xsl:value-of select="position()"/></td>
              <td><xsl:value-of select="current-grouping-key()"/></td>
			  <td><xsl:value-of select="./@country"/></td>
			  <td><xsl:value-of select="@name"/></td>
			  <td>
				<xsl:value-of select="current-group()/@name" separator=", "/>
			  </td>
			  <td>
				<xsl:value-of select="current-group()/@country" separator=", "/>
			  </td>
			  <td><xsl:value-of select="sum(current-group()/@pop)"/></td>
			</tr>
		  </xsl:for-each-group>
		</table>
	  </body>
	</html>
  </xsl:template>

</xsl:transform>
