<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:di="http://www.eclipse.org/papyrus/0.7.0/sashdi">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:variable name="delim" select="'#'"/>

  <xsl:template match="/">
        <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="children">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}">
          <xsl:choose>
            <xsl:when test="starts-with(., concat($delim, 'BDD', $delim))">
              <xsl:value-of select="substring-after(., concat($delim, 'BDD', $delim))"/>
            </xsl:when>
            <xsl:when test="starts-with(., concat($delim, '7016', $delim))">
              <xsl:value-of select="substring-after(., concat($delim, '7016', $delim))"/>
            </xsl:when>
            <xsl:when test="contains(., concat($delim, 'shape_uml_property_as_label'))">
              <xsl:value-of select="'shape_uml_property_as_label'"/>
            </xsl:when>
            <xsl:when test="contains(., concat($delim, 'shape_sysml_flowport_as_affixed'))">
              <xsl:value-of select="'shape_sysml_flowport_as_affixed'"/>
            </xsl:when>
            <xsl:when test="contains(., concat($delim, 'shape_sysml_block_as_composite'))">
              <xsl:value-of select="'shape_sysml_block_as_composite'"/>
            </xsl:when>
            <xsl:when test="contains(., concat($delim, 'shape_sysml_blockproperty_as_composite'))">
              <xsl:value-of select="'shape_sysml_blockproperty_as_composite'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="edges">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}">
          <xsl:choose>
            <xsl:when test="starts-with(., concat($delim, 'BDD', $delim))">
              <xsl:value-of select="substring-after(., concat($delim, 'BDD', $delim))"/>
            </xsl:when>
            <xsl:when test="contains(., concat($delim, 'link_uml_connector'))">
              <xsl:value-of select="'link_uml_connector'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>