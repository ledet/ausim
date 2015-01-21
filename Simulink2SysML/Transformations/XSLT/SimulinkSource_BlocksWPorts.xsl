<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinksource="http://simulinksource/1.0">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="2"/>

  <xsl:variable name="SkippedElementList" select="'|Port|'"/>
  <xsl:variable name="InportBlockTypeList" select="'|Terminator|Outport|'"/> <!-- BlockTypes to create an inport if it's not there in Properties -->
  <xsl:variable name="InportKeywordList" select="'|Inputs|'"/> <!-- Create inports if this keyword is found, also skip creation of a default inport -->
  <xsl:variable name="OutportBlockTypeList" select="'|Inport|'"/> <!-- BlockTypes to create an outport if it's not there in Properties -->
  <xsl:variable name="OutportKeywordList" select="'|Outputs|'"/> <!-- Create outports if this keyword is found, also skip creation of a default outport -->

  <xsl:template name="CreatePort">
    <xsl:param name="direction" select="."/>
    <xsl:param name="parentID" select="."/>
    <xsl:param name="num" select="."/>
    <xsl:param name="type" select="."/>
    <xsl:if test="$num > 1">
      <xsl:call-template name="CreatePort">
        <xsl:with-param name="direction" select="$direction"/>
        <xsl:with-param name="parentID" select="$parentID"/>
        <xsl:with-param name="num" select="$num - 1"/>
        <xsl:with-param name="type" select="$type"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="name">
      <xsl:if test="$direction = 'out'">
        <xsl:value-of select="(../Port[@Num = $num])[1]/@Name"/>
      </xsl:if>
    </xsl:variable>
    <xsl:text>&#xa;</xsl:text>
    <xsl:element name="Port">
      <xsl:attribute name="Direction"><xsl:value-of select="$direction"/></xsl:attribute>
      <!--<xsl:attribute name="Name"><xsl:value-of select="concat($parentID, '#', $direction, ':', $num, $nameIfFound)"/></xsl:attribute-->
      <xsl:attribute name="Name"><xsl:value-of select="$name"/></xsl:attribute>
      <xsl:attribute name="Num"><xsl:value-of select="$num"/></xsl:attribute>
      <xsl:if test="not($type = '')">
        <xsl:attribute name="Type"><xsl:value-of select="$type"/></xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="ArrayProcess">
    <xsl:param name="ArrayList" select="."/>
    <xsl:choose>
      <xsl:when test="contains($ArrayList, ',')">
        <xsl:value-of select="normalize-space(substring-before($ArrayList, ','))"/>
        <xsl:call-template name="ArrayProcess">
          <xsl:with-param name="ArrayList" select="normalize-space(substring-after($ArrayList, ','))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($ArrayList)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="GetPortDimensions">
    <xsl:value-of select="./Property[@Name='PortDimensions']/@Type"/><xsl:value-of select="./Property[@Name='PortDimensions']/@Value"/>
  </xsl:template>

  <xsl:template name="GetPortType">
    <xsl:variable name="dim"><xsl:call-template name="GetPortDimensions"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($dim, 'Array:Int')">
        <xsl:variable name="dimensions"><xsl:value-of select="substring($dim, 11, string-length($dim)-11)"/></xsl:variable>
        <xsl:variable name="modDim">
          <xsl:choose>
            <xsl:when test="substring($dimensions, string-length($dimensions)-2)=', 1'">
              <xsl:value-of select="substring($dimensions, 1, string-length($dimensions)-3)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$dimensions"/>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:variable>
         <xsl:value-of select="concat('Array:Float (', $modDim, ')')"/>
      </xsl:when>
      <xsl:when test="$dim = 'Int-1'"/>
      <xsl:otherwise><!-- Not reall sure what to do here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
        <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="tag" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="contains($SkippedElementList, concat('|', $tag, '|'))"/> <!-- Skipped Elements -->
      <xsl:when test="$tag='Property'">
        <xsl:variable name="name" select="@Name"/>
        <xsl:choose>
          <xsl:when test="$name='Ports'">
            <xsl:variable name="valueWOBrackets" select="substring-after(substring-before(normalize-space(@Value), ']'), '[')" /> <!-- for now assume form of [i, o] -->
            <xsl:variable name="InportCnt" select="substring-before($valueWOBrackets, ',')"/>
            <xsl:variable name="OutportCnt" select="substring(substring-after($valueWOBrackets, ','), 2)"/>
            <xsl:call-template name="CreatePort">
              <xsl:with-param name="direction" select="'in'"/>
              <xsl:with-param name="parentID" select="../@ID"/>
              <xsl:with-param name="num" select="$InportCnt"/>
              <xsl:with-param name="type" select="''"/>
            </xsl:call-template>
            <xsl:call-template name="CreatePort">
              <xsl:with-param name="direction" select="'out'"/>
              <xsl:with-param name="parentID" select="../@ID"/>
              <xsl:with-param name="num" select="$OutportCnt"/>
              <xsl:with-param name="type" select="''"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="contains($InportKeywordList, concat('|', $name, '|')) and not (../Property[@Name = 'Ports'])">
            <xsl:variable name="InportCnt" select="@Value"/>
            <xsl:call-template name="CreatePort">
              <xsl:with-param name="direction" select="'in'"/>
              <xsl:with-param name="parentID" select="../@ID"/>
              <xsl:with-param name="num" select="$InportCnt"/>
              <xsl:with-param name="type" select="''"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="contains($OutportKeywordList, concat('|', $name, '|')) and not (../Property[@Name = 'Ports'])">
            <xsl:variable name="OutportCnt" select="@Value"/>
            <xsl:call-template name="CreatePort">
              <xsl:with-param name="direction" select="'out'"/>
              <xsl:with-param name="parentID" select="../@ID"/>
              <xsl:with-param name="num" select="$OutportCnt"/>
              <xsl:with-param name="type" select="''"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:for-each select="@*">
                <xsl:variable name="value" select="."/>
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="$value"/>
                </xsl:attribute>
              </xsl:for-each>
              <xsl:apply-templates/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$tag='Port'">
        <xsl:if test="substring-before(@Name, '#') = ../@ID">
          <xsl:copy>
            <xsl:for-each select="@*">
              <xsl:variable name="value" select="."/>
              <xsl:attribute name="{name()}">
                <xsl:value-of select="$value"/>
              </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:for-each select="@*">
            <xsl:variable name="value" select="."/>
            <xsl:attribute name="{name()}">
              <xsl:value-of select="$value"/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="$tag='Block'">
              <xsl:variable name="type" select="@Type"/>
              <xsl:if test="contains($InportBlockTypeList, concat('|', $type, '|'))">
                <xsl:call-template name="CreatePort">
                  <xsl:with-param name="direction" select="'in'"/>
                  <xsl:with-param name="parentID" select="@ID"/>
                  <xsl:with-param name="num" select="1"/>
                  <xsl:with-param name="type"><xsl:call-template name="GetPortType"/></xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="contains($OutportBlockTypeList, concat('|', $type, '|'))">
                <xsl:call-template name="CreatePort">
                  <xsl:with-param name="direction" select="'out'"/>
                  <xsl:with-param name="parentID" select="@ID"/>
                  <xsl:with-param name="num" select="1"/>
                  <xsl:with-param name="type"><xsl:call-template name="GetPortType"/></xsl:with-param>
                </xsl:call-template>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>