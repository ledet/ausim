<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:di="http://www.eclipse.org/papyrus/0.7.0/sashdi">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:param name="ModelName" select="ModelName"/>
  <xsl:variable name="delim" select="'???'"/>

  <xsl:template match="/">
        <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="CreatePages">
    <xsl:param name="list" select="."/>
    <xsl:if test="contains($list, $delim)">
      <xsl:element name="availablePage">
        <xsl:element name="emfPageIdentifier">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($ModelName, '.notation#', substring-before($list, $delim))"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:call-template name="CreatePages">
        <xsl:with-param name="list" select="substring-after($list, $delim)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="CreateChildren">
    <xsl:param name="list" select="."/>
    <xsl:if test="contains($list, $delim)">
      <xsl:element name="children">
        <xsl:element name="emfPageIdentifier">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($ModelName, '.notation#', substring-before($list, $delim))"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:call-template name="CreateChildren">
        <xsl:with-param name="list" select="substring-after($list, $delim)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="GetDiagrams" match="/xmi:XMI">
    <xsl:variable name="diags">
      <xsl:for-each select="*">
        <xsl:variable name="tag" select="local-name()"/>
        <xsl:if test="$tag='Diagram' and @type='BlockDefinition'">
          <xsl:value-of select="@xmi:id"/><xsl:value-of select="$delim"/></xsl:if>
      </xsl:for-each>
      <xsl:for-each select="*">
        <xsl:variable name="tag" select="local-name()"/>
        <xsl:if test="$tag='Diagram' and @type='InternalBlock'">
          <xsl:value-of select="@xmi:id"/><xsl:value-of select="$delim"/></xsl:if>
      </xsl:for-each>
      <xsl:for-each select="*">
        <xsl:variable name="tag" select="local-name()"/>
        <xsl:if test="$tag='Diagram' and @type='PapyrusUMLActivityDiagram'">
          <xsl:value-of select="@xmi:id"/><xsl:value-of select="$delim"/></xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:element name="di:SashWindowsMngr">
      <xsl:attribute name="xmi:version">2.0</xsl:attribute>
      <!--<xsl:attribute name="xmlns:xmi">http://www.omg.org/XMI</xsl:attribute>
      <xsl:attribute name="xmlns:xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:attribute>
      <xsl:attribute name="xmlns:di">http://www.eclipse.org/papyrus/0.7.0/sashdi</xsl:attribute-->
      <xsl:element name="pageList">
        <xsl:call-template name="CreatePages">
          <xsl:with-param name="list" select="$diags"/>
        </xsl:call-template>
      </xsl:element>

      <xsl:element name="sashModel">
        <xsl:attribute name="currentSelection"><xsl:value-of select="'//@sashModel/@windows.0/@children.0'"/></xsl:attribute>
        <xsl:element name="windows">
          <xsl:element name="children">
            <xsl:attribute name="xsi:type"><xsl:value-of select="'di:TabFolder'"/></xsl:attribute>
            <xsl:call-template name="CreateChildren">
              <xsl:with-param name="list" select="$diags"/>
            </xsl:call-template>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>