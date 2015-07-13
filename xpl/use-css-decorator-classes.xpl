<?xml version="1.0" encoding="utf-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:html="http://www.w3.org/1999/xhtml"
  type="css:use-decorator-classes"
  name="use-decorator-classes"
  version="1.0">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Matches class names against supplied parsed CSS declarations (of css:expand).
    The class names may contain keywords, separated by '_-_'. If any of these keywords 
    are found in the parsed CSS as class selectors (.keyword), then the keywords are
    interpreted as class names on their own. They will be extracted from the remainder
    of the class name so that they are appended to the remainder, separated by space.</p>
    <p>The use case are workflows in which the complete styling is provided via external CSS
    rather than converted from InDesign or Word styles. By convention, users may include
    keywords in the style names, separated by tilde characters ('~'). These tildes
    will be converted to '_-_' in the conversion process. If they supply a class definition
    for a keyword, the compound typesetting style name will be interpreted as a base name
    plus decorator(s).</p>
    <p>To do: think about a way to skip this step for certain workflows, maybe by
    creating a front end pipeline that uses dynamic evaluation to optionally just
    do an identity transform or that supplies a different (identity) XSLT. The former
    option will be more efficient while the latter will be easier to set up.</p>
  </p:documentation>

  <p:input port="source" primary="true" >
    <p:documentation>HTML document in the HTML namespace</p:documentation>
  </p:input>
  <p:input port="stylesheet">
    <p:document href="../xsl/use-css-decorator-classes.xsl"/>
  </p:input>
  <p:output port="result" primary="true" >
    <p:documentation>Modified input document with potentially space-sepatated class 
    names where previously were compound names.</p:documentation>
  </p:output>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  <p:option name="discard-undeclared-styles" select="'no'" required="false">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Whether to also discard class attributes that, after splitting the decorators, are not declared in the CSS.</p>
  </p:documentation>
  </p:option>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="http://transpect.le-tex.de/css-expand/xpl/css.xpl"/>

  <css:parse name="parse"/>

  <p:sink/>

  <p:xslt name="apply">
    <p:input port="source">
      <p:pipe port="source" step="use-decorator-classes"/>
      <p:pipe port="result" step="parse"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="use-decorator-classes"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:with-param name="discard-undeclared-styles" select="$discard-undeclared-styles"/>
  </p:xslt>
  
  <letex:store-debug pipeline-step="use-css-decorator-classes/use-css-decorator-classes" extension="xhtml">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>

</p:declare-step>