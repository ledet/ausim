<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinkmm="http://simulinkmm/1.0">

<xsl:param name="settingsModel" select="document(settingsFileName)/ModelInformation/Model" />

<xsl:template name="Property_2_P" match="Property">
	<xsl:element name="P">
		<xsl:attribute name="Name">
			<xsl:value-of select="@Name"/>
		</xsl:attribute>

		<xsl:for-each select="Value">
			<xsl:choose>
				<xsl:when test="@xsi:type = 'simulinkmm:SimBool' ">
					<xsl:if test="@Value = 'true' ">
						<xsl:text>on</xsl:text>
					</xsl:if>

					<xsl:if test="@Value = 'false' ">
						<xsl:text>off</xsl:text>
					</xsl:if>
				</xsl:when>

				<xsl:when test="@xsi:type = 'simulinkmm:SimString' or @xsi:type = 'simulinkmm:SimInt' or @xsi:type = 'simulinkmm:SimFloat'">
					<xsl:value-of select="@Value" />
				</xsl:when>

				<xsl:when test="@xsi:type = 'simulinkmm:ValueArray'">
					<xsl:value-of select="'['" />

					<xsl:variable name="entryCount" select="count(./Entry)" />
					
					<xsl:for-each select="Entry">
						<xsl:value-of select="concat(@arrayValue, Value/@Value)" />

						<xsl:choose>
							<xsl:when test="position() = $entryCount">
								<xsl:value-of select="']'" />
							</xsl:when>
							<xsl:when test="position() != $entryCount and (../../@Name ='PortDimensions' or ../../@Name ='PortCounts')">
								<xsl:value-of select="' '" />
							</xsl:when>
							<xsl:when test="position() != $entryCount">
								<xsl:value-of select="', '" />
							</xsl:when>
						</xsl:choose>
						
					</xsl:for-each>

				</xsl:when>

			</xsl:choose>
		</xsl:for-each>
	</xsl:element>
</xsl:template>


<xsl:template name="Block_2_Block" match="Block">
	<xsl:element name="Block">
		<xsl:attribute name="BlockType">
			<xsl:value-of select="@BlockType"/>
		</xsl:attribute>

		<xsl:attribute name="Name">
			<xsl:value-of select="@Name"/>
		</xsl:attribute>
		
		<xsl:attribute name="SID">
			<xsl:value-of select="@SID"/>
		</xsl:attribute>

		<xsl:for-each select="Property">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Property_2_P" />
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>

		<xsl:for-each select="System">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="System_2_System" />
			<xsl:text>&#xa;</xsl:text>
		</xsl:for-each>

		<xsl:for-each select="Port">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Port_2_Port" />
			<xsl:text>&#xa;</xsl:text>
		</xsl:for-each>
		
	</xsl:element>
</xsl:template>


<xsl:template name="Port_2_Port" match="Port">
	<xsl:element name="Port">
		
		<xsl:for-each select="@*">
			<xsl:text>&#xa;</xsl:text>
			<xsl:element name="P">
				<xsl:attribute name="Name">
					<xsl:value-of select="name(.)"/>
				</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>
	</xsl:element>
</xsl:template>


<xsl:template name="Line_2_Line" match="Line">
	<xsl:element name="Line">
		<xsl:for-each select="Property">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Property_2_P" />
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>
	</xsl:element>
</xsl:template>


<xsl:template name="System_2_System" match="System">
	<xsl:element name="System">
		<xsl:for-each select="Property">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Property_2_P" />
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>

		<xsl:for-each select="Block">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Block_2_Block" />
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>

		<xsl:for-each select="Line">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="Line_2_Line" />
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>
	</xsl:element>
</xsl:template>


<xsl:template match="/simulinkmm:ModelInformation">
	<xsl:element name="ModelInformation">
		<xsl:attribute name="Version">
			<xsl:value-of select="@Version"/>
		</xsl:attribute>
		
		<xsl:for-each select="Model">
			<xsl:text>&#xa;</xsl:text>
			<xsl:element name="Model">
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/GraphicalInterface" />
				
				<xsl:for-each select="$settingsModel/P">
					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="." />
				</xsl:for-each>
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/ConfigManagerSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/EditorSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/SimulationSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/Verification" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/ExternalMode" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/EngineSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/ModelReferenceSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/ConfigurationSet" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/ConcurrentExecutionSettings" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/SystemDefaults" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/BlockDefaults" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/AnnotationDefaults" />
				
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/LineDefaults" />

				<xsl:for-each select="System">
					<xsl:text>&#xa;</xsl:text>
					<xsl:call-template name="System_2_System" />
				</xsl:for-each>
				<xsl:text>&#xa;</xsl:text>
			</xsl:element>
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>
	</xsl:element>
</xsl:template>


</xsl:stylesheet>
