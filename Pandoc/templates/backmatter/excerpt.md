$if(excerpt)$
$if(excerpt-title)$
# [$if(excerpt-preview)$$excerpt-preview$$else$A Preview of$endif$]{.kicker} $excerpt-title$ {#excerpt .backmatter}

::: bm-byline
$for(author)$$author$$sep$, $endfor$
:::
$if(excerpt-note)$

::: bm-subtitle
*$excerpt-note$*
:::
$endif$
$else$
# $if(excerpt-heading)$$excerpt-heading$$else$Excerpt$endif$ {#excerpt .backmatter}
$endif$

<!--dropcap-->

$excerpt$

::: bm-ornament
❦

*$if(excerpt-closing)$$excerpt-closing$$else$To be continued…$endif$*
:::
$endif$
