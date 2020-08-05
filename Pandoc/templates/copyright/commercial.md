# {epub:type=copyright-page}

<div style="font-size: small; font-family: sans-serif;">

<p style="text-indent: 0;">Copyright &copy;$year$ $for(author)$$author$$endfor$</p><br />
<p style="text-indent: 0;">All rights reserved. No part of this book may be reproduced or used in any manner without the prior written permission of the copyright owner, except for the use of brief quotations in critical articles and book reviews</p><br />

$if(email)$
<p style="text-indent: 0;">To request permissions, contact the author at $email$.</p><br />
$endif$

$if(paperback-isbn-13)$
<p style="text-indent: 0;">ISBN-13: $paperback-isbn-13$ (paperback)</p>
$endif$
$if(paperback-isbn-10)$
<p style="text-indent: 0;">ISBN-10: $paperback-isbn-10$ (paperback)</p>
$endif$
$if(hardcover-isbn-13)$
<p style="text-indent: 0;">ISBN-13: $hardcover-isbn-13$ (hardcover)</p>
$endif$
$if(hardcover-isbn-10)$
<p style="text-indent: 0;">ISBN-10: $hardcover-isbn-10$ (hardcover)</p>
$endif$
$if(epub-isbn-13)$
<p  style="text-indent: 0;">ISBN-13: $epub-isbn-13$ (ePub)</p>
$endif$
$if(epub-isbn-10)$
<p  style="text-indent: 0;">ISBN-10: $epub-isbn-10$ (ePub)</p>
$endif$

<br />

$if(lcc-info-html)$
<p style="text-indent: 0;">Library of Congress Cataloging-in-Publication Data:</p><br />
<p>$lcc-info-html$</p>
$endif$

$if(first-paperback-date)$
<p style="text-indent: 0;">First paperback edition $first-paperback-date$.</p><br />
$endif$

$if(contributors)$

$for(contributors)$
$if(contributors.artist)$
<p style="text-indent: 0;">Cover Artist: $for(contributors)$$contributors.artist$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.editor)$
<p style="text-indent: 0;">Editor: $for(contributors)$$contributors.editor$$endfor$</p><br />
$endif$
$endfor$

$for(contributors)$
$if(contributors.designer)$
<p style="text-indent: 0;">Design: $for(contributors)$$contributors.designer$$endfor$</p><br />
$endif$
$endfor$

<br />
$endif$

<p style="text-indent: 0;">Printed by $for(publisher)$$publisher$$endfor$ in the United States of America.</p><br />

<p style="text-indent: 0;">$for(publisher)$\noindent $publisher$$endfor$</p>
$if(publisher-address-html)$
<p style="text-indent: 0;">$publisher-address-html$</p><br />
$endif$

$for(website)$<p style="text-indent: 0;">$website$$endfor$</p>

</div>