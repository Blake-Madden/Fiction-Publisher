# {.unlisted epub:type=copyright-page}

<div style="font-size: small; font-family: sans-serif;">

<p style="text-indent: 0;">$if(copyright-header)$$copyright-header$$else$Copyright$endif$ &copy;$year$ $for(author)$$author$$endfor$</p><br />
$if(all-rights-reserved)$
<p style="text-indent: 0;">$all-rights-reserved$</p><br />
$else$
<p style="text-indent: 0;">All rights reserved. No part of this book may be reproduced or used in any manner without the prior written permission of the copyright owner, except for the use of brief quotations in critical articles and book reviews.</p><br />
$endif$

$if(email)$
<p style="text-indent: 0;">$if(request-permissions)$$request-permissions$$else$To request permissions, contact the author at$endif$ $email$.</p><br />
$endif$

$if(paperback-isbn-13)$
<p style="text-indent: 0;">ISBN-13: $paperback-isbn-13$ ($if(isbn-paperback-header)$$isbn-paperback-header$$else$paperback$endif$)</p>
$endif$
$if(paperback-isbn-10)$
<p style="text-indent: 0;">ISBN-10: $paperback-isbn-10$ ($if(isbn-paperback-header)$$isbn-paperback-header$$else$paperback$endif$)</p>
$endif$
$if(hardcover-isbn-13)$
<p style="text-indent: 0;">ISBN-13: $hardcover-isbn-13$ ($if(isbn-hardcover-header)$$isbn-hardcover-header$$else$hardcover$endif$)</p>
$endif$
$if(hardcover-isbn-10)$
<p style="text-indent: 0;">ISBN-10: $hardcover-isbn-10$ ($if(isbn-hardcover-header)$$isbn-hardcover-header$$else$hardcover$endif$)</p>
$endif$
$if(epub-isbn-13)$
<p  style="text-indent: 0;">ISBN-13: $epub-isbn-13$ ($if(isbn-epub-header)$$isbn-epub-header$$else$ePub$endif$)</p>
$endif$
$if(epub-isbn-10)$
<p  style="text-indent: 0;">ISBN-10: $epub-isbn-10$ ($if(isbn-epub-header)$$isbn-epub-header$$else$ePub$endif$)</p>
$endif$

<br />

$if(lcc-info-html)$
<p style="text-indent: 0;">$if(lcc-info-header)$$lcc-info-header$$else$Library of Congress Cataloging-in-Publication Data:$endif$</p><br />
<p>$lcc-info-html$</p>
$endif$

$if(first-paperback-date)$
<p style="text-indent: 0;">$if(first-paperback-header)$$first-paperback-header$$else$First paperback edition$endif$ $first-paperback-date$.</p><br />
$endif$

$if(contributors)$

$for(contributors)$
$if(contributors.cover-artist)$
<p style="text-indent: 0;">$if(cover-artist-header)$$cover-artist-header$$else$Cover Artist:$endif$ $for(contributors)$$contributors.cover-artist$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.illustrator)$
<p style="text-indent: 0;">$if(illustrator-header)$$illustrator-header$$else$Illustrator:$endif$ $for(contributors)$$contributors.illustrator$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.editor)$
<p style="text-indent: 0;">$if(editor-header)$$editor-header$$else$Editor:$endif$ $for(contributors)$$contributors.editor$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.designer)$
<p style="text-indent: 0;">$if(designer-header)$$designer-header$$else$Design:$endif$ $for(contributors)$$contributors.designer$$endfor$</p><br />
$endif$
$endfor$

<br />
$endif$

$if(publisher)$
<p style="text-indent: 0;">$for(publisher)$$publisher$$endfor$</p>
$endif$
$if(publisher-address-html)$
<p style="text-indent: 0;">$publisher-address-html$</p><br />
$endif$

$for(website)$
<p style="text-indent: 0;">$website$</p>
$endfor$

</div>