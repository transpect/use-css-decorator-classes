<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs html"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0">
  
  <xsl:template match="/">
    <xsl:variable name="raw-selectors" as="xs:string*"
      select="collection()/css:css/css:ruleset/css:selector[matches(@raw-selector, '^\.\i[-_a-z\d]+', 'i')]/@raw-selector"/>
    <xsl:variable name="decorator-regex" as="xs:string?"
      select="if (exists($raw-selectors)) then 
                concat(
                  '(',
                  string-join(
                    for $s in $raw-selectors
                    return substring($s, 2),
                    '|'
                  ),
                  ')(_-_|$)'
                )
                else ()"/>
    <xsl:next-match>
      <xsl:with-param name="decorator-class-regex" tunnel="yes" as="xs:string" select="$decorator-regex"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="@class">
    <xsl:param name="decorator-class-regex" as="xs:string?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$decorator-class-regex">
        <xsl:variable name="complete-list" as="xs:string*">
          <xsl:for-each select="tokenize(., '\s+')">
            <xsl:variable name="list-from-single-token" as="element(items)">
              <items>
                <xsl:for-each select="tokenize(., '_-_')">
                  <xsl:choose>
                    <xsl:when test="position() eq 1">
                      <!-- first token is base name, not decorator -->
                      <non-match>
                        <xsl:value-of select="."/>
                      </non-match>
                    </xsl:when>
                    <xsl:when test="matches(., $decorator-class-regex)">
                      <match>
                        <xsl:value-of select="."/>
                      </match>
                    </xsl:when>
                    <xsl:otherwise>
                      <non-match>
                        <xsl:value-of select="."/>
                      </non-match>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </items>
            </xsl:variable>
            <xsl:sequence select="string-join($list-from-single-token/non-match[normalize-space()], '_-_'),
                                  $list-from-single-token/match"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="class" select="distinct-values($complete-list[normalize-space()])" separator=" "/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="#default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>