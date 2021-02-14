# {epub:type=seriespage}

<div style="font-size: small; font-family: sans-serif;">

<p class="center top-margin" style="margin-bottom: 1em; font-style: italic;">$if(series-header)$$series-header$$else$Also Available$endif$</p>

$for(series-book1)$
$if(series-book1.link)$
<p class="center"><a href="$series-book1.link$">$series-book1.title$</a></p>
$else$
<p class="center">$series-book1.title$</p>
$endif$
$if(series-book1.subtitle)$
<p class="center">$series-book4.subtitle$</p>
$endif$
$endfor$

<div style="padding: 3em;" />

$for(series-book2)$
$if(series-book2.link)$
<p class="center"><a href="$series-book2.link$">$series-book2.title$</a></p>
$else$
<p class="center">$series-book2.title$</p>
$endif$
$if(series-book2.subtitle)$
<p class="center">$series-book4.subtitle$</p>
$endif$
$endfor$

<div style="padding: 3em;" />

$for(series-book3)$
$if(series-book3.link)$
<p class="center"><a href="$series-book3.link$">$series-book3.title$</a></p>
$else$
<p class="center">$series-book3.title$</p>
$endif$
$if(series-book3.subtitle)$
<p class="center">$series-book4.subtitle$</p>
$endif$
$endfor$

<div style="padding: 3em;" />

$for(series-book4)$
$if(series-book4.link)$
<p class="center"><a href="$series-book4.link$">$series-book4.title$</a></p>
$else$
<p class="center">$series-book4.title$</p>
$endif$
$if(series-book4.subtitle)$
<p class="center">$series-book4.subtitle$</p>
$endif$
$endfor$

<div style="padding: 3em;" />

$for(series-book5)$
$if(series-book5.link)$
<p class="center"><a href="$series-book5.link$">$series-book5.title$</a></p>
$else$
<p class="center">$series-book5.title$</p>
$endif$
$if(series-book5.subtitle)$
<p class="center">$series-book5.subtitle$</p>
$endif$
$endfor$

</div>
