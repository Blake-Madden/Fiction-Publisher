# {.unlisted epub:type=seriespage}

<div style="font-size: small; font-family: sans-serif;">

<p class="center top-margin" style="margin-bottom: 1em; font-style: italic;">$if(series-header)$$series-header$$else$Also Available$endif$</p>

$for(series-books)$
<div style="margin-bottom: 3em;">
$if(series-books.link)$
<p class="center"><a href="$series-books.link$">$series-books.title$</a></p>
$else$
<p class="center">$series-books.title$</p>
$endif$
$if(series-books.subtitle)$
<p class="center">$series-books.subtitle$</p>
$endif$
</div>

$endfor$
</div>
