$if(excerpt)$
$if(excerpt-title)$
# [A Preview of]{.kicker} $excerpt-title$ {#excerpt .backmatter}
$else$
# Excerpt {#excerpt .backmatter}
$endif$

::: bm-ornament
❦
:::

<!--dropcap-->

$excerpt$

::: bm-ornament
❦
:::
$if(excerpt-note)$

::: bm-subtitle
*$excerpt-note$*
:::
$endif$
$endif$
