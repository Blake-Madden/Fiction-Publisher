# {.unlisted epub:type=copyright-page}

<div style="font-size: small; font-family: sans-serif;">

<p class="center" style="text-indent: 0;">$title$</p>

<p class="center" style="text-indent: 0;">$if(copyright-header)$$copyright-header$$else$Copyright$endif$ &copy;$year$ $for(author)$$author$$endfor$</p>
<p class="center" style="text-indent: 0;">$if(some-rights-reserved)$$some-rights-reserved$$else$Some rights reserved.$endif$</p><br />

$if(publisher)$
<p class="center" style="text-indent: 0;">$if(published-by-header)$$published-by-header$$else$Published by$endif$</p>
<p class="center" style="text-indent: 0;">$for(publisher)$$publisher$$endfor$</p>
$endif$
$if(website)$
<p class="center" style="text-indent: 0;">$for(website)$$website$$endfor$</p>
$endif$
$if(publisher)$<br />$elseif(website)$<br />$endif$

<p class="center" style="text-indent: 0;">$if(cc-license-statement)$$cc-license-statement$$else$This book is distributed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.$endif$</p><br />

<img src="ccbynasa.png" class="center-image" height=46><br />

<p style="text-indent: 0;">$if(cc-free-header)$$cc-free-header$$else$That means you are free:$endif$</p><br />

<ul>
<li><strong>$if(cc-share-header)$$cc-share-header$$else$To Share$endif$</strong>---$if(cc-share)$$cc-share$$else$copy and redistribute the material in any medium or format.$endif$</li>
<li><strong>$if(cc-adapt-header)$$cc-adapt-header$$else$To Adapt$endif$</strong>---$if(cc-adapt)$$cc-adapt$$else$remix, transform, and build upon the material.$endif$</li>
</ul>
<br />

<p style="text-indent: 0;">$if(cc-terms-header)$$cc-terms-header$$else$The licensor cannot revoke these freedoms as long as you follow the license terms:$endif$</p><br />

<ul>
<li><strong>$if(cc-attribution-header)$$cc-attribution-header$$else$Attribution$endif$</strong>---$if(cc-attribution)$$cc-attribution$$else$You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.$endif$</li>
<li><strong>$if(cc-noncommercial-header)$$cc-noncommercial-header$$else$NonCommercial$endif$</strong>---$if(cc-noncommercial)$$cc-noncommercial$$else$You may not use the material for commercial purposes.$endif$</li>
<li><strong>$if(cc-sharealike-header)$$cc-sharealike-header$$else$ShareAlike$endif$</strong>---$if(cc-sharealike)$$cc-sharealike$$else$If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.$endif$</li>
</ul>
<br />

<p style="text-indent: 0;"><strong>$if(cc-no-restrictions-header)$$cc-no-restrictions-header$$else$No additional restrictions$endif$</strong>---$if(cc-no-restrictions)$$cc-no-restrictions$$else$You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.$endif$</p><br />

$for(contributors)$
$if(contributors.cover-artist)$
<p class="center" style="text-indent: 0;">$if(cover-artist-header)$$cover-artist-header$$else$Cover Artist:$endif$ $for(contributors)$$contributors.cover-artist$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.illustrator)$
<p class="center" style="text-indent: 0;">$if(illustrator-header)$$illustrator-header$$else$Illustrator:$endif$ $for(contributors)$$contributors.illustrator$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.editor)$
<p class="center" style="text-indent: 0;">$if(editor-header)$$editor-header$$else$Editor:$endif$ $for(contributors)$$contributors.editor$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.designer)$
<p class="center" style="text-indent: 0;">$if(designer-header)$$designer-header$$else$Design:$endif$ $for(contributors)$$contributors.designer$$endfor$</p><br />
$endif$
$endfor$

$if(paperback-isbn-13)$
<p class="center" style="text-indent: 0;">ISBN-13: $paperback-isbn-13$ ($if(isbn-paperback-header)$$isbn-paperback-header$$else$paperback$endif$)</p>
$endif$
$if(paperback-isbn-10)$
<p class="center" style="text-indent: 0;">ISBN-10: $paperback-isbn-10$ ($if(isbn-paperback-header)$$isbn-paperback-header$$else$paperback$endif$)</p>
$endif$
$if(hardcover-isbn-13)$
<p class="center" style="text-indent: 0;">ISBN-13: $hardcover-isbn-13$ ($if(isbn-hardcover-header)$$isbn-hardcover-header$$else$hardcover$endif$)</p>
$endif$
$if(hardcover-isbn-10)$
<p class="center" style="text-indent: 0;">ISBN-10: $hardcover-isbn-10$ ($if(isbn-hardcover-header)$$isbn-hardcover-header$$else$hardcover$endif$)</p>
$endif$
$if(epub-isbn-13)$
<p class="center"  style="text-indent: 0;">ISBN-13: $epub-isbn-13$ ($if(isbn-epub-header)$$isbn-epub-header$$else$ePub$endif$)</p>
$endif$
$if(epub-isbn-10)$
<p class="center"  style="text-indent: 0;">ISBN-10: $epub-isbn-10$ ($if(isbn-epub-header)$$isbn-epub-header$$else$ePub$endif$)</p>
$endif$

</div>