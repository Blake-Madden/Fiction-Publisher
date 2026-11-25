$if(praise)$
# $if(praise-title)$$praise-title$$else$Praise for *$title$*$endif$ {#praise .praise .unlisted}

$for(praise)$
::: praise-quote
$praise-open-quote$$praise.quote/chomp$$praise-close-quote$
:::

::: praise-source
—$praise.source$
:::

$endfor$
$endif$
