<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs html"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0">

  <xsl:param name="discard-undeclared-styles" select="'no'"/>

  <!-- We need to use the calculated XPath expressions in a generated stylesheet to match the selectors
    if we want to do it exactly -->
  <xsl:key name="raw-selector" match="css:selector" use="tokenize(@raw-selector, '\s+')"/>

  <xsl:variable name="css" select="(collection()[css:css])[1]" as="document-node(element(css:css))"/>

  <xsl:template match="@class">
    <xsl:variable name="elt-name" as="xs:string" select="name(..)"/>
    <xsl:variable name="complete-list" as="element(items)*">
      <xsl:for-each select="tokenize(., '\s+')">
        <items>
          <xsl:variable name="pre-tilde-split" select="." as="xs:string"/>
          <xsl:for-each select="tokenize(., '_-_')[normalize-space()]">
            <xsl:variable name="matching-selectors" as="element(css:selector)*"
              select="key('raw-selector', (concat('.', .), concat($elt-name, '.', .)), $css)"/>
            <xsl:choose>
              <xsl:when test="position() eq 1 
                              and not(starts-with($pre-tilde-split, '_-_'))">
                <!-- first token is base name, not decorator -->
                <xsl:choose>
                  <xsl:when test="$discard-undeclared-styles = 'no'
                                  or
                                  exists($matching-selectors)">
                    <!-- The base class. Even if it matches a class declaration, we treat it as a
                      'non-match' which means other non-matching classes of this token will be appended
                      to this base name. If it doesn’t match a class declaration, it will be discarded only
                      if $discard-undeclared-styles = 'yes' -->
                    <non-match>
                      <xsl:value-of select="."/>
                    </non-match>    
                  </xsl:when>
                  <xsl:otherwise>
                    <discard>
                      <xsl:value-of select="."/>
                    </discard>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="exists($matching-selectors)">
                <match>
                  <xsl:value-of select="."/>
                </match>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$discard-undeclared-styles = 'no'">
                    <non-match>
                      <xsl:value-of select="."/>
                    </non-match>    
                  </xsl:when>
                  <xsl:otherwise>
                    <discard>
                      <xsl:value-of select="."/>
                    </discard>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </items>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="class" as="xs:string" 
                  select="string-join(
                            distinct-values(
                              (
                                for $i in $complete-list
                                return string-join($i/non-match[normalize-space()], '_-_'),
                                $complete-list/match,
                                ''
                              )
                            ),
                            ' '
                          )"/>
    <xsl:if test="matches($class, '\S')">
      <xsl:attribute name="class" select="normalize-space($class)"/>
    </xsl:if>
    <xsl:if test="$complete-list/discard">
      <xsl:processing-instruction name="discard-classes" select="$complete-list/discard"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="#default">
    <xsl:copy>
      <xsl:apply-templates select="@* except @class, @class, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>