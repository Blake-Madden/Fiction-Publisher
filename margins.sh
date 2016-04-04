#!/bin/bash

echo "Please enter your page width in mm: "
read page_width

fib_inner_margin=$(echo "scale=12; $page_width * .111111111111" | bc)
fib_outer_margin=$(echo "scale=12; $page_width * .222222222222" | bc)
fib_top_margin=$(echo "scale=12; $page_width * .166666666667" | bc)
fib_bottom_margin=$(echo "scale=12; $page_width * .333333333333" | bc)

schrodingers_inner_margin=$(echo "scale=12; $page_width * .133" | bc)
schrodingers_outer_margin=$(echo "scale=12; $page_width * .141" | bc)
schrodingers_top_margin=$(echo "scale=12; $page_width * .178" | bc)
schrodingers_bottom_margin=$(echo "scale=12; $page_width * .141" | bc)

tvotc_inner_margin=$(echo "scale=12; $page_width * .176" | bc)
tvotc_outer_margin=$(echo "scale=12; $page_width * .110" | bc)
tvotc_top_margin=$(echo "scale=12; $page_width * .151" | bc)
tvotc_bottom_margin=$(echo "scale=12; $page_width * .151" | bc)

killingmoon_inner_margin=$(echo "scale=12; $page_width * .129" | bc)
killingmoon_outer_margin=$(echo "scale=12; $page_width * .137" | bc)
killingmoon_top_margin=$(echo "scale=12; $page_width * .151" | bc)
killingmoon_bottom_margin=$(echo "scale=12; $page_width * .144" | bc)

ancillary_inner_margin=$(echo "scale=12; $page_width * .122" | bc)
ancillary_outer_margin=$(echo "scale=12; $page_width * .144" | bc)
ancillary_top_margin=$(echo "scale=12; $page_width * .137" | bc)
ancillary_bottom_margin=$(echo "scale=12; $page_width * .151" | bc)

gunmachine_inner_margin=$(echo "scale=12; $page_width * .123" | bc)
gunmachine_outer_margin=$(echo "scale=12; $page_width * .109" | bc)
gunmachine_top_margin=$(echo "scale=12; $page_width * .167" | bc)
gunmachine_bottom_margin=$(echo "scale=12; $page_width * .065" | bc)

echo ""
echo "[Fibbonaci]"
echo "Inner margin: $fib_inner_margin mm"
echo "Outer margin: $fib_outer_margin mm"
echo "Top margin: $fib_top_margin mm"
echo "Bottom margin: $fib_bottom_margin mm"
echo "Text block height: $page_width mm"
echo ""
echo "[TVoTC]"
echo "Inner margin: $tvotc_inner_margin mm"
echo "Outer margin: $tvotc_outer_margin mm"
echo "Top margin: $tvotc_top_margin mm"
echo "Bottom margin: $tvotc_bottom_margin mm"
echo "Text block height: $page_width mm"
echo ""
echo "[Schrodinger's]"
echo "Inner margin: $schrodingers_inner_margin mm"
echo "Outer margin: $schrodingers_outer_margin mm"
echo "Top margin: $schrodingers_top_margin mm"
echo "Bottom margin: $schrodingers_bottom_margin mm"
echo "Text block height: $page_width mm"
echo ""
echo "[Killing Moon]"
echo "Inner margin: $killingmoon_inner_margin mm"
echo "Outer margin: $killingmoon_outer_margin mm"
echo "Top margin: $killingmoon_top_margin mm"
echo "Bottom margin: $killingmoon_bottom_margin mm"
echo "Text block height: $page_width mm"
echo ""
echo "[Ancillary]"
echo "Inner margin: $ancillary_inner_margin mm"
echo "Outer margin: $ancillary_outer_margin mm"
echo "Top margin: $ancillary_top_margin mm"
echo "Bottom margin: $ancillary_bottom_margin mm"
echo "Text block height: $page_width mm"
echo ""
echo "[Gun Machine]"
echo "Inner margin: $gunmachine_inner_margin mm"
echo "Outer margin: $gunmachine_outer_margin mm"
echo "Top margin: $gunmachine_top_margin mm"
echo "Bottom margin: $gunmachine_bottom_margin mm"
echo "Text block height: $page_width mm"
