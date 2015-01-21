<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinksourcemm="http://simulinksourcemm/1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:param name="ModelName" select="ModelName"/>

  <xsl:variable name="SkippedElementList" select="'|Stateflow|System|'"/>
  <xsl:variable name="AttributedElementList" select="'|Object|Array|Block|'"/>
  <xsl:variable name="SimulinkHeader" select="'***SimulinkPSM Settings***'"/>

  <xsl:template match="/">
        <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="tag" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="$tag='ModelInformation'"><xsl:apply-templates/></xsl:when>
      <xsl:when test="$tag='Model'">
        <xsl:element name="simulinksourcemm:Model">
          <xsl:attribute name="xmi:version">2.0</xsl:attribute>
          <xsl:attribute name="xsi:schemaLocation">http://simulinksourcemm/1.0 ../MetaModels/SimulinkSourceMM.ecore</xsl:attribute>
          <xsl:attribute name="Name">
            <xsl:value-of select="concat($ModelName, ' Settings')" />
          </xsl:attribute>
          <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:element name="ToSysMLComment"><xsl:attribute name="Body"><xsl:value-of select="$SimulinkHeader"/>&#xa;
            <xsl:apply-templates/>
          </xsl:attribute></xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($SkippedElementList, concat('|', $tag, '|'))"/> <!-- Skipped Elements -->
      <xsl:when test="contains($AttributedElementList, concat('|', $tag, '|'))"> <!-- Elements with Attributes -->
        &#60;<xsl:value-of select="$tag"/><xsl:for-each select="@*"><xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:for-each>&#62;&#xa;<xsl:apply-templates/>&#60;/<xsl:value-of select="$tag"/>&#62;&#xa;</xsl:when>
      <xsl:otherwise>
        &#60;<xsl:value-of select="$tag"/>&#62;&#xa;<xsl:apply-templates/>&#60;/<xsl:value-of select="$tag"/>&#62;&#xa;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="P">&#60;Property Name="<xsl:value-of select="@*"/>"&#62;<xsl:value-of select="."/>&#60;/Property&#62;&#xa;</xsl:template>

  <xsl:template match="Cell">&#60;Cell Class="<xsl:value-of select="@*"/>"&#62;<xsl:value-of select="."/>&#60;/Cell&#62;&#xa;</xsl:template>

</xsl:stylesheet>