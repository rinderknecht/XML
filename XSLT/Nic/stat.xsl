<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               exclude-result-prefixes="xs">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <xsl:call-template name="records">
      <xsl:with-param name="rec"
                      select="document(linkage/file/@name)/DSExport/Job/Record"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="records" as="element(Record)*">
    <xsl:param name="rec" as="element(Record)*"/>
    <xsl:for-each-group select="$rec" group-by="@Type">
      <xsl:copy>
        <xsl:sequence select="current-group()/@Type"/>
        <xsl:attribute name="Occ" select="count(current-group())"/>
        <xsl:for-each-group select="current-group()/Property" group-by="@Name">
          <xsl:call-template name="properties">
            <xsl:with-param name="key" select="current-grouping-key()"/>
            <xsl:with-param name="prop" select="current-group()"/>
          </xsl:call-template>
        </xsl:for-each-group>
        <xsl:for-each-group select="current-group()/Collection" group-by="@Name">
          <xsl:copy>
            <xsl:sequence select="@Name,@Type"/>
            <xsl:attribute name="Occ" select="count(current-group())"/>
            <xsl:call-template name="records">
              <xsl:with-param name="rec" select="current-group()/Record"/>
            </xsl:call-template>
          </xsl:copy>
        </xsl:for-each-group>
      </xsl:copy>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="properties" as="element(Property)">
    <xsl:param name="key" as="xs:anyAtomicType"/>
    <xsl:param name="prop" as="element(Property)*"/>
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:attribute name="Occ" select="count($prop)"/>
      <xsl:choose>
        <xsl:when test="$key = 'JobControlCode'">
          <Contents Occ="{count($prop)}">...</Contents>
        </xsl:when>
        <xsl:when test="$key = ('SqlPrimary','SqlRef','SqlInsert','SqlDelete','SqlUpdate','SqlWhere','SqlExtra')">
          <Contents Occ="{count($prop)}" Kind="s"/>
        </xsl:when> 
        <xsl:when test="$key = ('NextID','SourceID','StageXPos','StageYPos','StageXSize','StageYSize','DisplaySize','TopTextPos','LeftTextPos','ContainerViewSizing','ZoomValue','NextStageID','Precision','BackgroundColor','Catalog','Signature')">
          <Contents Occ="{count($prop)}" Kind="n"/>
        </xsl:when>
        <xsl:when test="$key = 'ExtendedType'">
          <xsl:variable name="kind" as="element(Property)*">
            <xsl:for-each-group select="$prop" group-by="text()">
              <xsl:copy>
                <xsl:analyze-string select="text()" regex="[0-9]+">
                  <xsl:matching-substring>n</xsl:matching-substring>
                  <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </xsl:copy>
            </xsl:for-each-group>
          </xsl:variable>
          <xsl:for-each-group select="$kind" group-by="text()">
            <Contents Occ="{count(current-group())}">
              <xsl:value-of select="current-grouping-key()"/>
            </Contents>
          </xsl:for-each-group>
        </xsl:when>
        <xsl:when test="$key = ('BeforeSubr','AfterSubr')">
          <Contents Occ="{count($prop)}" Kind="c"/>
        </xsl:when>
        <xsl:when test="$key = ('Name','UserName','TableName','Jobname','SourceColumn','PKeySourceColumn','Partner','SourceID','DSN','StageTypes','StageList','StageName','ColumnReference','SPName','TextFont','Parameters','Description','FullDescription','Password','Prompt','Category','Default','LogText','AnnotationText','Body','HelpTxt','JobSeqCodeGenOpts','Desc','ShortDesc','Value','DisplayValue','Column','ReferencedColumn','TestValues','Author','Copyright','DependentDLLs','RegDate','FunctionName')">
          <Contents Occ="{count($prop)}" Kind="x"/>
        </xsl:when>
        <xsl:when test="$key = ('FileName','TableDef','Path','ReferencedTable')">
          <Contents Occ="{count($prop)}" Kind="f"/>
        </xsl:when>
        <xsl:when test="$key = ('Derivation','ParsedDerivation','Expression','ParsedExpression','Constraint','ParsedConstraint','Transform','APTFieldProp','TriggerExpression','KeyExpression','PKeyParsedDerivation','Locator','APTRecordProp')">
          <Contents Occ="{count($prop)}" Kind="e"/>
        </xsl:when>
        <xsl:when test="$key = ('InputPins','OutputPins','SourceColumns','TableNames','DelimitedLoopValues')">
          <Contents Occ="{count($prop)}" Kind="l"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each-group select="$prop" group-by="text()">
            <Contents Occ="{count(current-group())}">
              <xsl:value-of select="current-grouping-key()"/>
            </Contents>
          </xsl:for-each-group>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
