# {.unlisted epub:type=copyright-page}

<div style="font-size: small; font-family: sans-serif;">

<p class="center" style="text-indent: 0;">$title$</p>

<p class="center" style="text-indent: 0;">$if(copyright-header)$$copyright-header$$else$Copyright$endif$ &copy;$year$ $for(author)$$author$$endfor$</p>
<p class="center" style="text-indent: 0;">Some rights reserved.</p><br />

$if(publisher)$
<p class="center" style="text-indent: 0;">Published by</p>
<p class="center" style="text-indent: 0;">$for(publisher)$$publisher$$endfor$</p>
$endif$
$if(website)$
<p class="center" style="text-indent: 0;">$for(website)$$website$$endfor$</p>
$endif$
$if(publisher)$<br />$elseif(website)$<br />$endif$

<p class="center" style="text-indent: 0;">This book is distributed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.</p><br />

<img src="ccbynasa.png" class="center-image" height=46><br />

<p style="text-indent: 0;">That means you are free:</p><br />

<ul>
<li><strong>To Share</strong>---copy and redistribute the material in any medium or format.</li>
<li><strong>To Adapt</strong>---remix, transform, and build upon the material.</li>
</ul>
<br />

<p style="text-indent: 0;">The licensor cannot revoke these freedoms as long as you follow the license terms:</p><br />

<ul>
<li><strong>Attribution</strong>---You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.</li>
<li><strong>NonCommercial</strong>---You may not use the material for commercial purposes.</li>
<li><strong>ShareAlike</strong>---If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.</li>
</ul>
<br />

<p style="text-indent: 0;"><strong>No additional restrictions</strong>---You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.</p><br />

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