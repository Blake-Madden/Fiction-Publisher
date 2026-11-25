$if(excerpt)$
$if(excerpt-title)$
# [A Preview of]{.kicker} $excerpt-title$ {#excerpt .backmatter}

::: bm-byline
$for(author)$$author$$sep$, $endfor$
:::
$if(excerpt-note)$

::: bm-subtitle
*$excerpt-note$*
:::
$endif$
$else$
# Excerpt {#excerpt .backmatter}
$endif$

<!--dropcap-->

$excerpt$

::: bm-ornament
❦

*To be continued…*
:::
$endif$
