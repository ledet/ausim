<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinkmm="http://simulinkmm/1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:template match="Cell">
    <xsl:element name="Cell">
      <xsl:attribute name="Grandparent">
            <xsl:value-of select="local-name(../parent::*)"/>
      </xsl:attribute>
      <xsl:if test="local-name(../parent::*)='Block'">
        <xsl:attribute name="BlockType">
            <xsl:value-of select="../../@BlockType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="Parent">
            <xsl:value-of select="local-name(./parent::*)"/>
      </xsl:attribute>
      <xsl:if test="local-name(./parent::*)='Block'">
        <xsl:attribute name="BlockType">
            <xsl:value-of select="../@BlockType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*">
          <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
          </xsl:attribute>
      </xsl:for-each>
      <xsl:attribute name="Value">
            <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="P">
    <xsl:element name="Property">
      <xsl:attribute name="Grandparent">
            <xsl:value-of select="local-name(../parent::*)"/>
      </xsl:attribute>
      <xsl:if test="local-name(../parent::*)='Block'">
        <xsl:attribute name="BlockType">
            <xsl:value-of select="../../@BlockType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="Parent">
            <xsl:value-of select="local-name(./parent::*)"/>
      </xsl:attribute>
      <xsl:if test="local-name(./parent::*)='Block'">
        <xsl:attribute name="BlockType">
            <xsl:value-of select="../@BlockType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*">
          <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
          </xsl:attribute>
      </xsl:for-each>
      <xsl:attribute name="Value">
            <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>