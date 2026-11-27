$if(glossary)$
# $if(glossary-title)$$glossary-title$$else$Glossary$endif$ {#glossary .backmatter .glossary}

::: glossary
$for(glossary)$
$if(glossary.group)$
::: glossary-group
$glossary.group$
:::

$endif$
$for(glossary.terms)$
[$glossary.terms.term$]{.glossary-term}$if(glossary.terms.pronunciation)$ ([$glossary.terms.pronunciation$]{.glossary-pronunciation})$endif$

:   $glossary.terms.definition$

$endfor$
$endfor$
:::
$endif$
