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
                <xsl:analyze-string select="." regex="{$decorator-class-regex}">
                  <xsl:matching-substring>
                    <match>
                      <xsl:value-of select="regex-group(1)"/>
                    </match>
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                    <non-match>
                      <xsl:value-of select="."/>
                    </non-match>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </items>
            </xsl:variable>
            <xsl:variable name="corrected-list" as="element(*)*">
              <xsl:apply-templates select="$list-from-single-token/*" mode="correct-for-first-non-match"/>  
            </xsl:variable>
            <xsl:sequence select="replace(
                                    replace(
                                      string-join($corrected-list[self::non-match], ''),
                                      '(_-_)+',
                                      '_-_'
                                    ),
                                    '_-_$',
                                    ''
                                  ), 
                                  $corrected-list[self::match]"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="class" select="distinct-values($complete-list[normalize-space()])" separator=" "/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[position() = 1]" mode="correct-for-first-non-match">
    <non-match position="{position()}">
      <xsl:value-of select="concat(.,'_-_')"/>
    </non-match>
  </xsl:template>
    
  <xsl:template match="* | @*" mode="correct-for-first-non-match #default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>