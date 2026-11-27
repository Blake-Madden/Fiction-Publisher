$if(cast)$
# $if(cast-title)$$cast-title$$else$Cast of Characters$endif$ {#cast .cast .unlisted}

$for(cast)$
$if(cast.group)$
::: cast-group
$cast.group$
:::

$endif$
$for(cast.characters)$
::: cast-entry
[$cast.characters.name$]{.cast-name}$if(cast.characters.description)$ — $cast.characters.description$$endif$
:::

$endfor$
$endfor$
$endif$
