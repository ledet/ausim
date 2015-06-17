<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinkmm="http://simulinkmm/1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:param name="ModelName" select="ModelName"/>

  <xsl:variable name="ChildBlockTypeList" select="'|SubSystem|ModelReference|'"/>
  <xsl:variable name="SkippedElementList" select="'|GraphicalInterface|ConfigManagerSettings|EditorSettings|SimulationSettings|Verification|ExternalMode|EngineSettings|ModelReferenceSettings|ConfigurationSet|ConcurrentExecutionSettings|SystemDefaults|BlockDefaults|AnnotationDefaults|LineDefaults|Stateflow|'"/><!-- Items being listed here that may need to be unskipped later SystemDefaults|BlockDefaults|AnnotationDefaults|LineDefaults -->
  <xsl:variable name="DefaultBlockPropertyList" select="'|Outputs|Port|PortDimensions|OutDataTypeStr|BusOutputAsStruct|FunctionName|PortCounts|'"/><!-- May need to add to this list as more block types are researched -->
  <xsl:variable name="BlockPropertyList" select="'|Outputs|Port|PortDimensions|OutDataTypeStr|BusOutputAsStruct|FunctionName|PortCounts|Ports|Tag|Value|relop|const|Gain|Position|'"/><!-- May need to add to this list as more block types are researched -->
  <xsl:variable name="SystemPropertyList" select="'||'"/><!-- May need to add to this list as more block types are researched -->

  <xsl:template name="ProcessPrimitiveType">
    <xsl:param name="PrimitiveValue" select="."/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:element name="Value">
      <xsl:attribute name="xsi:type">
        <xsl:choose>
          <xsl:when test="translate($PrimitiveValue, 'ON', 'on') = 'on'"> <!-- Boolean-->
            <xsl:value-of select="'simulinkmm:SimBool'"/>
          </xsl:when>
          <xsl:when test="translate($PrimitiveValue, 'OF', 'of') = 'off'"> <!-- Boolean-->
            <xsl:value-of select="'simulinkmm:SimBool'"/>
          </xsl:when>
          <xsl:when test="string(number($PrimitiveValue)) = 'NaN'"> <!-- String-->
            <xsl:value-of select="'simulinkmm:SimString'"/>
          </xsl:when>
          <xsl:when test="floor($PrimitiveValue) != $PrimitiveValue or contains($PrimitiveValue, '.')"> <!-- Decimal-->
            <xsl:value-of select="'simulinkmm:SimFloat'"/>
          </xsl:when>
          <xsl:otherwise> <!-- Integer-->
            <xsl:value-of select="'simulinkmm:SimInt'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="Value">
        <xsl:choose>
          <xsl:when test="translate($PrimitiveValue, 'ON', 'on') = 'on'"> <!-- Boolean-->
            <xsl:value-of select="'true'"/>
          </xsl:when>
          <xsl:when test="translate($PrimitiveValue, 'OF', 'of') = 'off'"> <!-- Boolean-->
            <xsl:value-of select="'false'"/>
          </xsl:when>
          <xsl:otherwise> <!-- Others-->
            <xsl:value-of select="$PrimitiveValue"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="ProcessArrayPortion">
    <xsl:param name="ArrayPortion" select="."/>
    <xsl:param name="delimList" select="."/>
    <xsl:param name="index" select="."/>
    <xsl:choose>
      <xsl:when test="string-length($delimList) > 1">
        <xsl:call-template name="ArraySplit">
          <xsl:with-param name="ArrayList" select="$ArrayPortion"/>
          <xsl:with-param name="delimList" select="substring($delimList, 2)"/>
          <xsl:with-param name="index" select="$index"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="string-length($ArrayPortion) > 0">
          <xsl:text>&#xa;</xsl:text>
          <xsl:element name="Entry">
            <xsl:attribute name="Index">
              <xsl:value-of select="$index"/>
            </xsl:attribute>
              <xsl:call-template name="ProcessPrimitiveType">
                <xsl:with-param name="PrimitiveValue" select="$ArrayPortion"/>
              </xsl:call-template>
          </xsl:element>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <xsl:template name="ArraySplit">
    <xsl:param name="ArrayList" select="."/>
    <xsl:param name="delimList" select="."/>
    <xsl:param name="index" select="."/>
    <xsl:choose>
      <xsl:when test="contains($ArrayList, substring($delimList, 1, 1))">
        <xsl:variable name="ArrayPortion" select="normalize-space(substring-before($ArrayList, substring($delimList, 1, 1)))"/>
        <xsl:call-template name="ProcessArrayPortion">
          <xsl:with-param name="ArrayPortion" select="$ArrayPortion"/>
          <xsl:with-param name="delimList" select="$delimList"/>
          <xsl:with-param name="index" select="$index"/>
        </xsl:call-template>
        <xsl:call-template name="ArraySplit">
          <xsl:with-param name="ArrayList" select="normalize-space(substring-after($ArrayList, substring($delimList, 1, 1)))"/>
          <xsl:with-param name="delimList" select="$delimList"/>
          <xsl:with-param name="index" select="$index+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ProcessArrayPortion">
          <xsl:with-param name="ArrayPortion" select="$ArrayList"/>
          <xsl:with-param name="delimList" select="$delimList"/>
          <xsl:with-param name="index" select="$index"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
        <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="tag" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="$tag='ModelInformation'">
        <xsl:element name="simulinkmm:ModelInformation">
          <xsl:attribute name="xmi:version">2.0</xsl:attribute>
          <xsl:attribute name="xsi:schemaLocation">http://simulinkmm/1.0 ../MetaModels/SimulinkMM.ecore</xsl:attribute>
          <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$tag='Model'">
        <xsl:copy>
          <xsl:attribute name="Name">
            <xsl:value-of select="$ModelName" />
          </xsl:attribute>
          <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$tag='Block' and local-name(./parent::*)='BlockParameterDefaults'">
        <xsl:element name="BlockParams">
          <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$tag='Port'">
        <xsl:element name="Port">
          <xsl:for-each select="P">
            <xsl:attribute name="{@*}"><xsl:value-of select="." /></xsl:attribute>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($SkippedElementList, concat('|', $tag, '|'))"/> <!-- Skipped Elements -->
      <xsl:otherwise>
        <xsl:copy>
          <xsl:for-each select="@*">
            <xsl:variable name="value" select="."/>
            <xsl:choose>
              <xsl:when test="$tag='Block' and name()='BlockType' and contains($ChildBlockTypeList, concat('|', $value, '|')) and local-name(../parent::*)='System'">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="$value"/>
                </xsl:attribute>
                <xsl:attribute name="xsi:type">
                  <xsl:value-of select="concat('simulinkmm:', $value, 'Block')" />
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="$tag='Array' and name()='Dimension' and substring($value, 1, 2)='1*'">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="substring($value, 3)"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="$tag='Array' and name()='Type'">
                <xsl:attribute name="xsi:type">
                  <xsl:value-of select="concat('simulinkmm:', $value, 'Array')" />
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="$value"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="P">
    <xsl:variable name="name" select="@Name"/>
    <xsl:choose>
      <xsl:when test="not(contains($BlockPropertyList, concat('|', $name, '|'))) and local-name(../parent::*)='BlockParameterDefaults' or local-name(./parent::*)='Model'"></xsl:when>
      <xsl:when test="not(contains($BlockPropertyList, concat('|', $name, '|'))) and local-name(./parent::*)='Block'"></xsl:when>
      <xsl:when test="not(contains($SystemPropertyList, concat('|', $name, '|'))) and local-name(./parent::*)='System'"></xsl:when>
      <xsl:otherwise>
        <xsl:element name="Property">
          <xsl:for-each select="@*">
              <xsl:attribute name="{name()}">
                  <xsl:value-of select="."/>
              </xsl:attribute>
          </xsl:for-each>
          <xsl:variable name="value" select="." />
          <xsl:variable name="valueWOSpace" select="normalize-space(.)" />
          <xsl:choose>
            <xsl:when test="substring($valueWOSpace, 1, 1) = '[' and substring($valueWOSpace, string-length($valueWOSpace), 1) = ']'">
              <xsl:text>&#xa;</xsl:text>
              <xsl:element name="Value">
              <xsl:attribute name="xsi:type">
                <xsl:value-of select="'simulinkmm:ValueArray'"/>
              </xsl:attribute>
                <xsl:if test="string-length($valueWOSpace) > 2">
                  <xsl:call-template name="ArraySplit">
                    <xsl:with-param name="ArrayList" select="substring($valueWOSpace, 2, string-length($valueWOSpace)-2)"/>
                    <xsl:with-param name="delimList" select="';, '"/>
                    <xsl:with-param name="index" select="0"/>
                  </xsl:call-template>
                  <xsl:text>&#xa;</xsl:text>
                </xsl:if>
              </xsl:element>
              <xsl:text>&#xa;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="ProcessPrimitiveType">
                <xsl:with-param name="PrimitiveValue" select="$value"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Cell">Cell Class(<xsl:value-of select="@Class"/>)="<xsl:value-of select="."/>"</xsl:template>

  <xsl:template match="Object">Object Attributes(<xsl:for-each select="@*"><xsl:value-of select="name()"/>="<xsl:value-of select="."/>" </xsl:for-each>) {<xsl:apply-templates/><xsl:text>&#xa;</xsl:text>}<xsl:text>&#xa;</xsl:text></xsl:template>

  <xsl:template match="Array">Array Attributes(<xsl:for-each select="@*"><xsl:value-of select="name()"/>="<xsl:value-of select="."/>" </xsl:for-each>) {<xsl:apply-templates/><xsl:text>&#xa;</xsl:text>}<xsl:text>&#xa;</xsl:text></xsl:template>

</xsl:stylesheet>