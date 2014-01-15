<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
     xmlns:dct="http://purl.org/dc/terms/"
     xmlns:frbr="http://purl.org/vocab/frbr/core#"
     xmlns:pica="http://www.ub.uni-marburg.de/webcat/card/ppn/"
     version="1.0" >

<xsl:output method="xml" encoding="UTF-8" indent="yes" />

<xsl:template match="rdf:RDF">
 <add>
  <xsl:apply-templates select="rdf:Description" />
 </add>
</xsl:template>

<xsl:template match="rdf:Description">
  <xsl:choose>
   <xsl:when test="starts-with(pica:f002Y,'T')">
     <!-- Normdaten -->
   </xsl:when>
   <xsl:otherwise>
   <doc>
    <field name="recordtype">opac</field>
    <field name="id"><xsl:value-of select="pica:f003Y"/></field>
    <xsl:apply-templates select="pica:*" />
    <xsl:apply-templates select="frbr:exemplar" />
    <field name="allfields">
       <xsl:for-each select="//*/pica:*">
          <xsl:value-of select="' ['"/>
          <xsl:value-of select="substring(local-name(.),2)"/>
          <xsl:value-of select="'] '"/>
          <xsl:value-of select="normalize-space(string(.))"/>
          <xsl:value-of select="' '"/>
       </xsl:for-each>
    </field>
    </doc>
    <!-- <xsl:apply-templates select="pica:f004A" /> -->
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="pica:f021A">
  <xsl:choose>
    <xsl:when test="pica:Sub">
    <field name="title">
        <xsl:value-of select="translate(pica:Sub/pica:a,'@','')"/>
        <xsl:if test="pica:Sub/pica:d">
        <xsl:value-of select="' : '"/>
        <xsl:value-of select="translate(pica:Sub/pica:d,'@','')"/>
        </xsl:if>
    </field>
    <field name="title_sort">
        <xsl:value-of select="pica:Sub/pica:a"/>
    </field>
    </xsl:when>
    <xsl:otherwise>
    <!-- title_fullStr title_full_unstemmed copy machine -->
    <field name="title"><xsl:value-of select="translate(.,'@','')"/></field>
    <field name="title_full">
           <xsl:value-of select="translate(.,'@','')"/></field>
    <field name="title_sort">
           <xsl:value-of select="."/></field>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="pica:f028A">
 <xsl:choose>
  <xsl:when test="pica:Sub/pica:d">
    <field name="author">
      <xsl:value-of select="concat(pica:Sub/pica:d,' ',pica:Sub/pica:a)"/>
    </field>
    <field name="authorStr"><xsl:value-of select="pica:Sub/pica:a"/></field>
  </xsl:when>
  <xsl:when test="pica:Sub/pica:x8">
    <field name="author"><xsl:value-of select="pica:Sub/pica:x8"/></field>
    <field name="authorStr"><xsl:value-of select="pica:Sub/pica:x8"/></field>
  </xsl:when>
  <xsl:when test="../pica:f021A/pica:Sub/pica:h">
    <field name="author">
           <xsl:value-of select="../pica:f021A/pica:Sub/pica:h"/>
    </field>
    <field name="authorStr">
           <xsl:value-of select="../pica:f021A/pica:Sub/pica:h"/>
    </field>
  </xsl:when>
  <xsl:when test="../pica:f036C/pica:Sub/pica:h">
    <field name="author">
           <xsl:value-of select="../pica:f036C/pica:Sub/pica:h"/>
    </field>
    <field name="authorStr">
           <xsl:value-of select="../pica:f036C/pica:Sub/pica:h"/>
    </field>
  </xsl:when>
  <xsl:when test="pica:Aut/pica:aut">
    <field name="author"><xsl:value-of select="pica:Aut/pica:aut"/></field>
  </xsl:when>
  <xsl:otherwise>
    <field name="author"><xsl:value-of select="."/></field>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Autor ist Herausgeber -->
<xsl:template match="pica:f028C">
 <xsl:choose>
  <xsl:when test="pica:Sub/pica:d">
    <field name="author2">
      <xsl:value-of select="concat(pica:Sub/pica:d,' ',pica:Sub/pica:a)"/>
    </field>
    <field name="author2-role"><xsl:value-of select="'Hrsg.'"/></field>
  </xsl:when>
  <xsl:when test="pica:Sub/pica:x8">
    <field name="author2">
      <xsl:value-of select="pica:Sub/pica:x8"/>
    </field>
    <field name="author2-role"><xsl:value-of select="'Hrsg.'"/></field>
  </xsl:when>
  <xsl:otherwise>
  <!--
    <field name="author"><xsl:value-of select="pica:Sub/pica:x8"/></field>
  -->
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Autor ist Koerperschaft -->
<xsl:template match="pica:f029F">
 <xsl:choose>
  <xsl:when test="../pica:f028A">
    <field name="author2">
      <xsl:value-of select="concat(pica:Sub/pica:d,' ',pica:Sub/pica:a)"/>
    </field>
    <field name="author2-role"><xsl:value-of select="'Körperschaft'"/></field>
  </xsl:when>
  <xsl:when test="pica:Sub/pica:x8">
    <field name="author2">
      <xsl:value-of select="pica:Sub/pica:x8"/>
    </field>
    <field name="author2-role"><xsl:value-of select="'Körperschaft'"/></field>
  </xsl:when>
  <xsl:otherwise>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Bandtitel 001719394 -->
<xsl:template match="pica:f036C">
  <field name="hierarchy_parent_title">
      <xsl:value-of select="translate(pica:Sub/pica:a,'@','')"/>
  </field>
 <!--
 <xsl:if test="not(../pica:f021A)">
 </xsl:if>
 <field name="hierarchy_top_id">
        <xsl:value-of select="../pica:f003Y"/>
 </field>
 <field name="series"><xsl:value-of select="pica:Sub/pica:d"/></field>
 -->
</xsl:template>

 <!-- GH201311 TODO Stuttgarter Sezession 010110437 -->
<xsl:template match="pica:f036D">
 <field name="hierarchy_parent_id">
        <xsl:value-of select="pica:Sub/pica:x9"/>
 </field>
 <field name="hierarchy_top_id">
        <xsl:value-of select="pica:Sub/pica:x9"/>
 </field>
</xsl:template>

<xsl:template match="pica:f033A">
    <field name="publisher">
        <xsl:value-of select="concat(pica:Sub/pica:n,' ',pica:Sub/pica:p)"/>
    </field>
</xsl:template>

<!-- LANGUAGE -->
<xsl:template match="pica:f010Y">
  <xsl:variable name="lang">
   <xsl:choose>
    <xsl:when test="pica:Sub/pica:a">
     <xsl:value-of select="pica:Sub/pica:a[position()=1]"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="."/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <field name="language">
   <xsl:choose>
     <xsl:when test="$lang='ara'">Arabic</xsl:when>
     <xsl:when test="$lang='dan'">Danish</xsl:when>
     <xsl:when test="$lang='eng'">English</xsl:when>
     <xsl:when test="$lang='fre'">French</xsl:when>
     <xsl:when test="$lang='dut'">Nederlands</xsl:when>
     <xsl:when test="$lang='ger'">German</xsl:when>
     <xsl:when test="$lang='heb'">Hebrew</xsl:when>
     <xsl:when test="$lang='ita'">Italian</xsl:when>
     <xsl:when test="$lang='jpn'">Japanese</xsl:when>
     <xsl:when test="$lang='lat'">Latin</xsl:when>
     <xsl:when test="$lang='per'">Persian</xsl:when>
     <xsl:when test="$lang='pol'">Polish</xsl:when>
     <xsl:when test="$lang='rus'">Russian</xsl:when>
     <xsl:when test="$lang='spa'">Spanish</xsl:when>
     <xsl:when test="$lang='tur'">Turkish</xsl:when>
     <xsl:when test="$lang='mul'">Multiple</xsl:when>
     <xsl:when test="$lang='swe'">Swedish</xsl:when>
     <xsl:otherwise><xsl:value-of select="$lang"/></xsl:otherwise>
   </xsl:choose>
  </field>
</xsl:template>

<!-- DATE : difficult -->
<!--
<xsl:template match="pica:f001B">
  <xsl:variable name="tVal" select="substring-after(pica:Sub/x0,':')" />
  <field name="mod_date">
  <xsl:value-of select="concat('20',substring($tVal,7,2),'-'
                ,substring($tVal,4,2),'-',substring($tVal,1,2),'T00:00:01Z')"/>
  </field>
</xsl:template>
-->

<xsl:template match="pica:f011Y">
  <xsl:choose>
  <xsl:when test=".='20XX'">
     <field name="publishDate"><xsl:value-of select="'0000'" /></field>
  </xsl:when>
  <xsl:when test="pica:Sub">
     <field name="publishDate"><xsl:value-of select="pica:Sub/pica:a"/></field>
     <field name="publishDateSort">
            <xsl:value-of select="pica:Sub/pica:a"/></field>
     <field name="era">
            <xsl:value-of select="substring(pica:Sub/pica:a,0,5)" /></field>
     <field name="era_facet">
            <xsl:value-of select="substring(pica:Sub/pica:a,0,5)" /></field>
  </xsl:when>
  <xsl:otherwise>
  <field name="publishDate"><xsl:value-of select="." /></field>
  <field name="publishDateSort"><xsl:value-of select="." /></field>
  <field name="era"><xsl:value-of select="substring(.,0,5)" /></field>
  <field name="era_facet"><xsl:value-of select="substring(.,0,5)" /></field>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ISBN -->
<xsl:template match="pica:f004A">
 <xsl:choose>
  <xsl:when test="pica:Sub/pica:x0">
    <field name="isbn"><xsl:value-of select="pica:Sub/pica:x0"/></field>
  </xsl:when>
  <xsl:when test="pica:Sub/pica:A">
    <field name="isbn"><xsl:value-of select="pica:Sub/pica:A"/></field>
  </xsl:when>
  <xsl:otherwise>
    <field name="isbn"><xsl:value-of select="."/></field>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- ISSN -->
<xsl:template match="pica:f005A">
 <xsl:choose>
  <xsl:when test="pica:Sub/pica:x0">
    <field name="issn"><xsl:value-of select="pica:Sub/pica:x0"/></field>
  </xsl:when>
  <xsl:when test="pica:Sub/pica:A">
    <field name="issn"><xsl:value-of select="pica:Sub/pica:A"/></field>
  </xsl:when>
  <xsl:otherwise>
    <field name="issn"><xsl:value-of select="."/></field>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- link name from pica:x3 to some dynamic field ? -->
<!--
<xsl:template match="pica:f009P">
    <field name="url"><xsl:value-of select="pica:u"/></field>
</xsl:template>
-->

<!-- hopefully, this are all online resources -->
<xsl:template match="pica:f009Q">
 <xsl:for-each select="pica:Sub/pica:u">
    <field name="url"><xsl:value-of select="."/></field>
 </xsl:for-each>
</xsl:template>

<!-- Afu : Druckschrift, unselbständig, Autopsie -->
<xsl:template match="pica:f002Y">
  <xsl:choose>
   <xsl:when test="starts-with(.,'A')"> <!-- Druckschriften -->
    <field name="institution"><xsl:value-of select="'Print'"/></field>
    <xsl:choose>
     <xsl:when test="substring(.,2,1)='a'"> 
        <field name="format"><xsl:value-of select="'Book'"/></field>
     </xsl:when>
    </xsl:choose>
   </xsl:when>

   <xsl:when test="starts-with(.,'B')">
     <field name="format"><xsl:value-of select="'Audio'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'C')">
     <field name="format"><xsl:value-of select="'Braille'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'E')">
     <field name="format"><xsl:value-of select="'Film'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'G')">
     <field name="format"><xsl:value-of select="'CD'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'H')">
     <field name="format"><xsl:value-of select="'Writing'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'I')">
     <field name="format"><xsl:value-of select="'Illustrated'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'K')">
     <field name="format"><xsl:value-of select="'Maps'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'L')"> <!-- Luy -->
     <field name="format"><xsl:value-of select="'Lokal'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'M')">
     <field name="format"><xsl:value-of select="'Music'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'O')">
    <field name="institution"><xsl:value-of select="'Online'"/></field>
    <xsl:choose>
      <xsl:when test="substring(.,2,1)='a'"> 
         <field name="format"><xsl:value-of select="'eBook'"/></field>
      </xsl:when>
    </xsl:choose>
   </xsl:when>

   <xsl:when test="starts-with(.,'S')">
     <field name="format"><xsl:value-of select="'DVD'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'T')">
     <field name="format"><xsl:value-of select="'Normdaten'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'V')">
     <field name="format"><xsl:value-of select="'Objects'"/></field>
   </xsl:when>

   <xsl:when test="starts-with(.,'Z')">
     <field name="format"><xsl:value-of select="'Multimedia'"/></field>
   </xsl:when>

   <xsl:otherwise>
     <field name="format"><xsl:value-of select="'Unknown'"/></field>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
     <xsl:when test="substring(.,2,1)='b'"> 
        <field name="format"><xsl:value-of select="'Journal'"/></field>
     </xsl:when>
     <!-- Gesamttitelaufnahme eines mehrbändigen begrenzten Werkes -->
     <xsl:when test="substring(.,2,1)='c'"> <!-- Serial or Series -->
        <field name="format"><xsl:value-of select="'Volume Holdings'"/></field>
        <field name="is_hierarchy_id">
               <xsl:value-of select="../pica:f003Y"/>
        </field>
        <field name="hierarchy_top_id">
               <xsl:value-of select="../pica:f003Y"/>
        </field>
        <field name="hierarchy_top_title">
        <xsl:value-of select="translate(../pica:f021A/pica:Sub/pica:a,'@','')"/>
        </field>
     </xsl:when>
     <!-- Gesamttitelaufnahme einer Schriftenreihe -->
     <xsl:when test="substring(.,2,1)='d'"> <!-- Serial or Series -->
        <field name="format"><xsl:value-of select="'Volume Holdings'"/></field>
     </xsl:when>
     <xsl:when test="substring(.,2,1)='f'"> <!-- Bandauffuehrung -->
        <field name="format"><xsl:value-of select="'Serial'"/></field>
        <field name="is_hierarchy_id">
               <xsl:value-of select="../pica:f003Y"/>
        </field>
     </xsl:when>
     <!-- einbändiger Stuecktitel eines mehrbaendigen Werkes -->
     <xsl:when test="substring(.,2,1)='F'"> 
        <field name="format"><xsl:value-of select="'Serial'"/></field>
        <field name="is_hierarchy_id">
               <xsl:value-of select="../pica:f003Y"/>
        </field>
     </xsl:when>
     <xsl:when test="substring(.,2,1)='o'"> <!-- Aufsatz -->
        <field name="format"><xsl:value-of select="'Article'"/></field>
     </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- 048924202 /vol/vol01/data/pica.db/mod-048943762.rdf -->
<!-- 019899408 /vol/vol01/data/pica.db/mod-020040210.rdf -->
<xsl:template match="rdf:RDF/rdf:Description/pica:f036E[1]">
 <xsl:choose>
 <xsl:when test="following-sibling::pica:f036E">
 </xsl:when>
 <xsl:when test="../pica:f021A">
   <field name="container_title">
     <xsl:value-of select="translate(pica:Sub/pica:a,'@','')"/>
   </field>
 </xsl:when>
 <xsl:otherwise>
   <field name="container_title">
     <xsl:value-of select="translate(pica:Sub/pica:a,'@','')"/>
   </field>
   <field name="title">
     <xsl:value-of select="translate(pica:Sub/pica:a,'@','')"/>
   </field>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- DDC -->
<xsl:template match="pica:f045B">
  <field name="dewey-full"><xsl:value-of select="pica:Sub/pica:a"/></field>
  <field name="dewey-hundreds">
         <xsl:value-of select="substring-before(pica:Sub/pica:a,'.')"/>
  </field>
</xsl:template>

<xsl:template match="pica:f045Z">
  <xsl:choose>
  <xsl:when test="following-sibling::pica:f045Z">
  </xsl:when>
  <xsl:otherwise>
    <field name="callnumber"><xsl:value-of select="."/></field>
    <field name="callnumber-a">
           <xsl:value-of select="substring-before(.,' ')"/>
    </field>
    <field name="callnumber-first">
           <xsl:value-of select="substring(.,1,2)"/></field>
    <field name="callnumber-subject"><xsl:value-of select="."/></field>
  </xsl:otherwise>
  </xsl:choose>
  <!--
  <field name="callnumber-label">
     <xsl:value-of select="concat('RVK ', .)"/>
  </field>
  -->
  <!--
  <field name="callnumber-first-code"><xsl:value-of select="."/></field>
  <field name="lccn"><xsl:value-of select="."/></field>
  -->

  <!--
  <field name="ctrlnum"><xsl:value-of select="."/></field>
  <field name="genre"><xsl:value-of select="."/></field>
  <field name="genre_facet"><xsl:value-of select="."/></field>
  -->
</xsl:template>

<xsl:template match="pica:f003O">
  <field name="oclc_num"><xsl:value-of select="pica:Sub/pica:x0"/></field>
</xsl:template>

<xsl:template match="pica:t009Q">
  <field name="url"><xsl:value-of select="rdf:Description/pica:u"/></field>
</xsl:template>

<!-- dct:extend -->
<xsl:template match="pica:f034D">
  <field name="physical"><xsl:value-of select="."/></field>
</xsl:template>

<xsl:template match="pica:t034I">
  <field name="physical"><xsl:value-of select="rdf:Description/pica:a"/></field>
</xsl:template>
<xsl:template match="dct:extend">
  <field name="physical"><xsl:value-of select="."/></field>
</xsl:template>

<xsl:template match="pica:f044F">
  <field name="topic"><xsl:value-of select="."/></field>
  <field name="topic_facet"><xsl:value-of select="." /></field>
  <field name="topic_browse"><xsl:value-of select="." /></field>
</xsl:template>
<!--
<xsl:template match="pica:f044F|pica:f041A|pica:f041A_01|pica:f041A_02|pica:f041A_03|pica:f041A_04|pica:f041A_05|pica:f044K|pica:f044K">
</xsl:template>
-->

<xsl:template match="pica:f144Z">
  <field name="topic"><xsl:value-of select="."/></field>
</xsl:template>

<xsl:template match="pica:f044N">
  <field name="topic"><xsl:value-of select="."/></field>
</xsl:template>

<xsl:template match="frbr:exemplar">
 <xsl:apply-templates select="rdf:Description/pica:*" />
 <xsl:if test="position()=1 and rdf:Description/pica:f209A/pica:Sub/pica:a">
  <field name="callnumber-label">
    <xsl:value-of select="rdf:Description/pica:f209A/pica:Sub/pica:a"/> 
  </field>
 </xsl:if>
</xsl:template>

<xsl:template match="pica:f209A">
  <xsl:choose>
   <xsl:when test="pica:Sub/pica:f">
   <field name="building">
       <xsl:value-of select="concat('205/',pica:Sub/pica:f)"/> 
   </field>
   </xsl:when>
   <xsl:otherwise>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- suppress emptyness -->
<xsl:template match="text()"/>

</xsl:stylesheet>