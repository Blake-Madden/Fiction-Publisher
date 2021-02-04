# {epub:type=copyright-page}

<div style="font-size: small; font-family: sans-serif;">

<p class="center" style="text-indent: 0;">$title$</p>

<p class="center" style="text-indent: 0;">Copyright &copy;$year$ $for(author)$$author$$endfor$</p>
<p class="center" style="text-indent: 0;">Some rights reserved.</p><br />

<p class="center" style="text-indent: 0;">Published in the United States by</p>
<p class="center" style="text-indent: 0;">$for(publisher)$$publisher$$endfor$</p>
<p class="center" style="text-indent: 0;">$for(website)$$website$$endfor$</p><br />

<p class="center" style="text-indent: 0;">This book is distributed under a Creative Commons attribution-Non-Commercial-Sharealike 4.0 License.</p><br />

<img src="ccbynasa.png" class="center-image" height=46><br />

<p style="text-indent: 0;">That means you are free:</p><br />

<ul>
<li><strong>To Share</strong> -- copy and redistribute the material in any medium or format.</li>
<li><strong>To Adapt</strong> -- remix, transform, and build upon the material.</li>
</ul>
<br />

<p style="text-indent: 0;">The licensor cannot revoke these freedoms as long as you follow the license terms:</p><br />

<ul>
<li><strong>Attribution</strong> -- You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.</li>
<li><strong>Non-Commercial</strong> -- You may not use the material for commercial purposes.</li>
<li><strong>Share Alike</strong> -- If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.</li>
</ul>
<br />

<p style="text-indent: 0;"><strong>No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.</strong></p><br />

$for(contributors)$
$if(contributors.cover-artist)$
<p class="center" style="text-indent: 0;">Cover Artist: $for(contributors)$$contributors.cover-artist$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.editor)$
<p class="center" style="text-indent: 0;">Editor: $for(contributors)$$contributors.editor$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.designer)$
<p class="center" style="text-indent: 0;">Design: $for(contributors)$$contributors.designer$$endfor$</p><br />
$endif$
$endfor$

$if(paperback-isbn-13)$
<p class="center" style="text-indent: 0;">ISBN-13: $paperback-isbn-13$ (paperback)</p>
$endif$
$if(paperback-isbn-10)$
<p class="center" style="text-indent: 0;">ISBN-10: $paperback-isbn-10$ (paperback)</p>
$endif$
$if(hardcover-isbn-13)$
<p class="center" style="text-indent: 0;">ISBN-13: $hardcover-isbn-13$ (hardcover)</p>
$endif$
$if(hardcover-isbn-10)$
<p class="center" style="text-indent: 0;">ISBN-10: $hardcover-isbn-10$ (hardcover)</p>
$endif$
$if(epub-isbn-13)$
<p class="center"  style="text-indent: 0;">ISBN-13: $epub-isbn-13$ (ePub)</p>
$endif$
$if(epub-isbn-10)$
<p class="center"  style="text-indent: 0;">ISBN-10: $epub-isbn-10$ (ePub)</p>
$endif$

</div>