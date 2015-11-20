<?xml version="1.0" encoding="utf-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:html="http://www.w3.org/1999/xhtml"
  name="test"
  version="1.0">

  
  <p:input port="source" primary="true">
    <p:document href="test.html"/>
  </p:input>
  <p:output port="result" primary="true"/>
  
  <p:option name="debug" required="false" select="'yes'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/use-css-decorator-classes/xpl/use-css-decorator-classes.xpl"/>
  
  <css:use-decorator-classes name="map-styles">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </css:use-decorator-classes>
  
</p:declare-step>