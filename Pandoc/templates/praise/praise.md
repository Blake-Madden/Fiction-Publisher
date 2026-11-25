$if(praise)$
# $if(praise-title)$$praise-title$$else$Praise for *$title$*$endif$ {#praise .praise .unlisted}

$for(praise)$
::: praise-quote
$quote-open$$praise.quote/chomp$$quote-close$
:::

::: praise-source
—$praise.source$
:::

$endfor$
$endif$
