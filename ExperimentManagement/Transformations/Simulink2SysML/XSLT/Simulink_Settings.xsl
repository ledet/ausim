<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:variable name="MatchedElementList" select="'|Model|ModelInformation|GraphicalInterface|ConfigManagerSettings|EditorSettings|SimulationSettings|Verification|ExternalMode|EngineSettings|ModelReferenceSettings|ConfigurationSet|ConcurrentExecutionSettings|SystemDefaults|BlockDefaults|AnnotationDefaults|LineDefaults|Cell|Array|Object|System|'"/>
  <xsl:variable name="SkippedPropertyList" select="'|NumRootInports|NumRootOutports|NumModelReferences|NumTestPointedSignals|SIDHighWatermark|SIDPrevWatermark|'"/>

  <xsl:template match="*">
    <xsl:if test="contains($MatchedElementList, concat('|', local-name(), '|'))">
      <xsl:copy>
        <xsl:for-each select="@*">
          <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="P">
    <xsl:if test="not(contains($SkippedPropertyList, concat('|', @Name, '|')))">
      <xsl:copy>
        <xsl:for-each select="@*">
          <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>