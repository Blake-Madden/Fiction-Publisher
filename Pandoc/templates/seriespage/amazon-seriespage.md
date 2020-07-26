# {epub:type=seriespage}

<div style="font-size: small; font-family: sans-serif;">

<p class="center top-margin" style="margin-bottom: 1em; font-style: italic;">$if(series-header)$$series-header$$else$Also Available$endif$</p>

$for(book1)$$if(book1.link)$
<p class="center"><a href="$book1.link$">$book1.title$</a></p>
$else$
<p class="center">$book1.title$</p>
$endif$
$endfor$

$for(book2)$$if(book2.link)$
<p class="center"><a href="$book2.link$">$book2.title$</a></p>
$else$
<p class="center">$book2.title$</p>
$endif$
$endfor$

$for(book3)$$if(book3.link)$
<p class="center"><a href="$book3.link$">$book3.title$</a></p>
$else$
<p class="center">$book3.title$</p>
$endif$
$endfor$

$for(book4)$$if(book4.link)$
<p class="center"><a href="$book4.link$">$book4.title$</a></p>
$else$
<p class="center">$book4.title$</p>
$endif$
$endfor$

$for(book5)$$if(book5.link)$
<p class="center"><a href="$book5.link$">$book5.title$</a></p>
$else$
<p class="center">$book5.title$</p>
$endif$
$endfor$

</div>
