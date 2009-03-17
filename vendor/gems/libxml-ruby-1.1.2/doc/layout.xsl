<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output cdata-section-elements="script"/>

  <xsl:template match="/">

    <html>
      <head>
        <title>Libxml</title>
        <link rel="stylesheet" href="css/normal.css" />
        <link REL='SHORTCUT ICON' HREF="img/xml-ruby.png" />
      </head>
      <body>
      <div class="container">

        <table>
          <tr valign="top">
            <td class='navlinks'>
              <img src="img/red-cube.jpg" align="top" style="margin-left: -100px;"/>

              <br/><br/>

              <strong>Navigation</strong><br/>
              <li><a href="index.xml">Home</a></li>
              <li><a href="install.xml">Installation</a></li>
              <li><a href="license.xml">License</a></li>
              <li><a href="rdoc/index.html">API Docs</a></li>
              <br/>
              <strong>Development</strong><br/>
              <li><a href="http://rubyforge.org/projects/libxml">Rubyforge</a></li>
              <li><a href="http://rubyforge.org/tracker/?group_id=494">Tickets</a></li>
              <li><a href="http://rubyforge.org/mail/?group_id=494">Mail Lists</a></li>
              <li><a href="http://rubyforge.org/forum/?group_id=494">Forums</a></li>
              <li><a href="http://rubyforge.org/news/?group_id=494">News</a></li>
              <li><a href="http://rubyforge.org/scm/?group_id=494">Source</a></li>
              <li><a href="http://rubyforge.org/frs/?group_id=494">Files</a></li>
              <br/>
              <strong>External</strong><br/>
              <li><a href="http://groups.google.com/group/libxml-devel">List on Google</a></li>         
              <li><a href="http://xmlsoft.org/">Libxml2 project</a></li>
            </td>
            <td style="padding: 10px;">
              <h1 class="title"><span style="color: red;">LibXml</span> Ruby Project</h1>

              <xsl:apply-templates />
            </td>
          </tr>
        </table>

        <div class='copyright'>
          Copyright &#x00A9; 2001-2006 Libxml-Ruby project contributors.<br/>
          Website is, yea baby!, pure XML/XSLT<br/>
        </div>

      </div>
      </body>
    </html>

  </xsl:template>

  <xsl:template match="content">
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>

