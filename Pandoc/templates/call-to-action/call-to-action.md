$if(call-to-action)$
# $if(call-to-action-title)$$call-to-action-title$$else$Before You Go$endif$ {#call-to-action .backmatter .call-to-action}

::: bm-ornament
❦
:::

::: cta-text
$call-to-action$
:::

::: bm-byline
$for(author)$$author$$sep$, $endfor$
:::

$for(call-to-action-links)$
<p class="cta-link"><a href="$if(amazon)$$if(call-to-action-links.link-amazon)$$call-to-action-links.link-amazon$$else$$call-to-action-links.link$$endif$$else$$call-to-action-links.link$$endif$">$call-to-action-links.label$</a></p>

$endfor$
$endif$
