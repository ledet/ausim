<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmi:version="2.0" xsi:schemaLocation="http://www.omg.org/XMI" xmlns:xalan="http://xml.apache.org/xalan" xmlns:simulinkmm="http://simulinkmm/1.0">

	<xsl:param name="settingsFileName" select="settingsFileName"/>
	<xsl:param name="settingsModel" select="document($settingsFileName)/ModelInformation" />
	
	<xsl:variable name="numRootInports">
		<xsl:value-of select="count(simulinkmm:ModelInformation/Model/System/Block[@BlockType = 'Inport'])" />
	</xsl:variable>
	<xsl:variable name="numRootOutports">
		<xsl:value-of select="count(simulinkmm:ModelInformation/Model/System/Block[@BlockType = 'Outport'])" />
	</xsl:variable>

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
				<xsl:call-template name="System_2_System">
					<xsl:with-param name="isSubSystem" select=" 'true' " />
				</xsl:call-template>
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
		<xsl:param name="isSubSystem" select="."/>
		<xsl:element name="System">
			<xsl:if test="$isSubSystem = 'false' ">
				<xsl:text>&#xa;</xsl:text>
				<xsl:copy-of select="$settingsModel/Model/System/P" />
			</xsl:if>
			
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

	<xsl:template name="System_2_GraphicalInterface" match="simulinkmm:ModelInformation/Model">
		<xsl:element name="GraphicalInterface">							
			<xsl:text>&#xa;</xsl:text>
			<xsl:element name="P">
				<xsl:attribute name="Name">
					<xsl:text>NumRootInports</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$numRootInports" />
			</xsl:element>
			<xsl:text>&#xa;</xsl:text>

			<xsl:for-each select="System/Block">
				<xsl:if test="@BlockType='Inport' ">
					<xsl:element name="Inport">
						<xsl:text>&#xa;</xsl:text>
						<xsl:element name="P">
							<xsl:attribute name="Name">
								<xsl:text>BusObject</xsl:text>
							</xsl:attribute>
						</xsl:element>

						<xsl:text>&#xa;</xsl:text>
						<xsl:element name="P">
							<xsl:attribute name="Name">
								<xsl:text>Name</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="@Name" />
						</xsl:element>
						<xsl:text>&#xa;</xsl:text>

					</xsl:element>
					<xsl:text>&#xa;</xsl:text>
				</xsl:if>
			</xsl:for-each>

			
			<xsl:element name="P">
				<xsl:attribute name="Name">
					<xsl:text>NumRootOutports</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$numRootOutports" />
			</xsl:element>

			<xsl:text>&#xa;</xsl:text>
			<xsl:for-each select="System/Block">
				<xsl:if test="@BlockType='Outport' ">
					<xsl:element name="Outport">
						<xsl:text>&#xa;</xsl:text>
						<xsl:element name="P">
							<xsl:attribute name="Name">
								<xsl:text>BusObject</xsl:text>
							</xsl:attribute>
						</xsl:element>
						
						<xsl:text>&#xa;</xsl:text>
						<xsl:element name="P">
							<xsl:attribute name="Name">
								<xsl:text>BusOutputAsStruct</xsl:text>
							</xsl:attribute>
							<xsl:text>off</xsl:text>
						</xsl:element>

						<xsl:text>&#xa;</xsl:text>
						<xsl:element name="P">
							<xsl:attribute name="Name">
								<xsl:text>Name</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="@Name" />
						</xsl:element>
						<xsl:text>&#xa;</xsl:text>

					</xsl:element>
					<xsl:text>&#xa;</xsl:text>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:for-each select="$settingsModel/Model/GraphicalInterface/P">	
				<xsl:copy-of select="." />
				<xsl:text>&#xa;</xsl:text>
			</xsl:for-each>

		</xsl:element>		
	</xsl:template>


	<xsl:template match="simulinkmm:ModelInformation">
		<xsl:element name="ModelInformation">
			<xsl:attribute name="Version">
				<xsl:value-of select="@Version"/>
			</xsl:attribute>

			<xsl:for-each select="Model">
				<xsl:text>&#xa;</xsl:text>
				<xsl:element name="Model">
					<xsl:text>&#xa;</xsl:text>

					<xsl:call-template name="System_2_GraphicalInterface" />					

					<xsl:for-each select="$settingsModel/Model/P">
						<xsl:text>&#xa;</xsl:text>
						<xsl:copy-of select="." />
					</xsl:for-each>

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/ConfigManagerSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/EditorSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/SimulationSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/Verification" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/ExternalMode" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/EngineSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/ModelReferenceSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/ConfigurationSet" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/ConcurrentExecutionSettings" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/SystemDefaults" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/BlockDefaults" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/AnnotationDefaults" />

					<xsl:text>&#xa;</xsl:text>
					<xsl:copy-of select="$settingsModel/Model/LineDefaults" />

					<xsl:for-each select="System">
						<xsl:text>&#xa;</xsl:text>
						<xsl:call-template name="System_2_System">
							<xsl:with-param name="isSubSystem" select=" 'false' " />
						</xsl:call-template>
					</xsl:for-each>
					<xsl:text>&#xa;</xsl:text>
				</xsl:element>
			</xsl:for-each>
			<xsl:text>&#xa;</xsl:text>

			<xsl:copy-of select="$settingsModel/Stateflow" />
			<xsl:text>&#xa;</xsl:text>

		</xsl:element>
	</xsl:template>


</xsl:stylesheet>
