#!/usr/bin/env bash
# Creates an (Inkscape friendly/compatiible) SVG
# of a pictorial representation of a Stenography keyboard.
# The created image is suitable for later editing by a script.

# parameters/variables/settings
ROWS=4
COLS=12
NULL_VALUE="_"
RES_SVG_FILE="stenoboard_full.svg"
ROW_HEIGHT=250
ROW_0_HEIGHT=50
COL_WIDTH=150
ROW_SEP=20
COL_SEP=5
SPLIT_HANDS=false
SPLIT_HANDS=true
HANDS_SEP=200
BORDER=50
STROKE_COLOR="#000000"
STROKE_WIDTH=2.0
FILL_COLOR="#11D118"
FILL_OPACITY=0.5
LABEL_COLOR="#000000"
LABEL_OPACITY=0.4
LABEL_FONT_SIZE=50
LABEL_FONT_TYPE="Courier 10 Pitch"

declare -a SIDES=("l" "r")

NV="${NULL_VALUE}"
#declare -a LABELS0=("#"   "#" "#" "#" "#" "#" "#" "#" "#" "#" "#" "#")
declare -a LABELS1=("Fn1" "S" "T" "P" "H" "*" "*" "F" "P" "L" "T" "D")
declare -a LABELS2=("Fn2" "S" "K" "W" "R" "*" "*" "R" "B" "G" "S" "Z")
declare -a LABELS3=($NV   $NV $NV "A" "O" $NV $NV "E" "U" $NV $NV $NV )

#declare -a IDS0=("Sharpl1"   "Sharpl2" "Sharpl3" "Sharpl4" "Sharpl5" "Sharpl6" "Sharpr1" "Sharpr2" "Sharpr3" "Sharpr4" "Sharpr5" "Sharpr6")
declare -a IDS1=("Fn1" "S${SIDES[0]}1" "T${SIDES[0]}" "P${SIDES[0]}" "H"            "Star${SIDES[0]}1" "Star${SIDES[1]}1" "F"            "P${SIDES[1]}" "L" "T${SIDES[1]}" "D")
declare -a IDS2=("Fn2" "S${SIDES[0]}2" "K"            "W"            "R${SIDES[0]}" "Star${SIDES[0]}2" "Star${SIDES[1]}2" "R${SIDES[1]}" "B"            "G" "S${SIDES[1]}" "Z")
declare -a IDS3=($NV   $NV $NV "A" "O" $NV $NV "E" "U" $NV $NV $NV )

for (( ri=0; ri < ${ROWS}; ri++)); do
	for (( ci=0; ci < ${COLS}; ci++)); do
		var="LABELS$ri[$ci]"
		echo -n "${!var} "
	done
	echo ""
done

# derived values
let IMG_WIDTH="(2 * ${BORDER}) + (${COLS} * (${COL_WIDTH} + ${COL_SEP})) - ${COL_SEP}"
if [ "${SPLIT_HANDS}" == "true" ]
then
	let IMG_WIDTH="${IMG_WIDTH} + ${HANDS_SEP}"
fi
let IMG_HEIGHT="(2 * ${BORDER}) + (${ROWS} * (${ROW_HEIGHT} + ${ROW_SEP}) - ${ROW_SEP}) - ${ROW_HEIGHT} + ${ROW_0_HEIGHT}"
let COLS_HALF="${COLS} / 2"





cat > "${RES_SVG_FILE}" << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="${IMG_WIDTH}"
   height="${IMG_HEIGHT}"
   id="StenographyKeyboard"
   version="1.1"
   inkscape:version="0.48.4 r9939"
   sodipodi:docname="stenoKeyboard.svg">
  <defs
     id="defs4" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="0.98994949"
     inkscape:cx="518.26749"
     inkscape:cy="648.97366"
     inkscape:document-units="px"
     inkscape:current-layer="layerKeyFills"
     showgrid="false"
     inkscape:window-width="1278"
     inkscape:window-height="730"
     inkscape:window-x="0"
     inkscape:window-y="0"
     inkscape:window-maximized="1" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
      </cc:Work>
    </rdf:RDF>
  </metadata>
EOF


function numberBar() {
	style="${1}"
	layer="${2}"

ri=0
let x="${BORDER}"
let y="${BORDER}"
let width="((${COLS} / 2) * (${COL_WIDTH} + ${COL_SEP})) - ${COL_SEP}"
let height="${ROW_0_HEIGHT}"
idBase="keySharp"
if [ "${SPLIT_HANDS}" == "true" ]; then
	for (( ci=0; ci < 2; ci++)); do
		let x="${BORDER} + (${ci} * (${width} + ${HANDS_SEP}))"
		side="${SIDES[${ci}]}"
		id="${idBase}${side}"
		cat >> "${RES_SVG_FILE}" << EOF
    <rect
       style="${style}"
       id="keySharp${side}${layer}"
       width="${width}"
       height="${height}"
       x="${x}"
       y="${y}"
       rx="0"
       ry="0" />
EOF
	done
else
	let width="(${width} * 2) + ${COL_SEP}"
	cat >> "${RES_SVG_FILE}" << EOF
    <rect
       style="${style}"
       id="${idBase}${layer}"
       width="${width}"
       height="${height}"
       x="${x}"
       y="${y}"
       rx="0"
       ry="0" />
EOF
fi
}



# Rows 1 to 3
function mainRows() {
	style="${1}"
	layer="${2}"

let width="${COL_WIDTH}"
let height="${ROW_HEIGHT}"
for (( ri=1; ri < ${ROWS}; ri++)); do
	let y="${BORDER} + ${ROW_0_HEIGHT} + ${ROW_SEP} + ((${ri} - 1) * (${ROW_SEP} + ${ROW_HEIGHT}))"
	for (( ci=0; ci < ${COLS}; ci++)); do
		let x="${BORDER} + (${ci} * (${COL_WIDTH} + ${COL_SEP}))"
		if [ "${SPLIT_HANDS}" == "true" ] && [ ${ci} -ge ${COLS_HALF} ]; then
			let x="${x} - ${COL_SEP} + ${HANDS_SEP}"
		fi
		var="IDS$ri[$ci]"
		id="${!var}"
		if [ "${id}" == "${NULL_VALUE}" ]; then
			continue
		fi
		#var="LABELS$ri[$ci]"
		#label="${!var}"
		if [ ${ri} -gt 1 ]; then
			round=true
		else
			round=false
		fi
		if [ "${round}" = "true" ]; then
			let xEnd="${x} + ${COL_WIDTH}"
			let radius="${COL_WIDTH} / 2"
			let yEnd="${y} + ${ROW_HEIGHT} - ${radius}"
			cat >> "${RES_SVG_FILE}" << EOF
    <path
       style="${style}"
       id="key${id}${layer}"
       d="M ${xEnd},${yEnd} L ${xEnd},${y} L ${x},${y} L ${x},${yEnd} A ${radius},${radius} 0 0,0 ${xEnd},${yEnd}"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cssscc" />
EOF
		else
			cat >> "${RES_SVG_FILE}" << EOF
    <rect
       style="${style}"
       id="key${id}${layer}"
       width="${width}"
       height="${height}"
       x="${x}"
       y="${y}"
       rx="0"
       ry="0" />
EOF
		fi
	done
done
}


function numberBarLabel() {
	style="${1}"

ri=0
let y="${BORDER} + (${ROW_0_HEIGHT} / 2) + (${LABEL_FONT_SIZE} / 4)"
let width="((${COLS} / 2) * (${COL_WIDTH} + ${COL_SEP})) - ${COL_SEP}"
let height="${ROW_0_HEIGHT}"
label="#"
idBase="keySharp"
if [ "${SPLIT_HANDS}" == "true" ]; then
	for (( ci=0; ci < 2; ci++)); do
		let x="${BORDER} + (${width} / 2) + (${ci} * (${width} + ${HANDS_SEP}))"
		side="${SIDES[${ci}]}"
		id="${idBase}${side}"
		cat >> "${RES_SVG_FILE}" << EOF
    <text
       xml:space="preserve"
       style="${style}"
       x="${x}"
       y="${y}"
       id="${id}Label"
       sodipodi:linespacing="125%"><tspan
         sodipodi:role="line"
         id="${id}LabelTSpan"
         x="${x}"
         y="${y}">${label}</tspan></text>
EOF
	done
else
	let width="(${width} * 2) + ${COL_SEP}"
	let x="${BORDER} + (${width} / 2)"
	let id="${idBase}"
	cat >> "${RES_SVG_FILE}" << EOF
    <text
       xml:space="preserve"
       style="${style}"
       x="${x}"
       y="${y}"
       id="${id}Label"
       sodipodi:linespacing="125%"><tspan
         sodipodi:role="line"
         id="${id}LabelTSpan"
         x="${x}"
         y="${y}">${label}</tspan></text>
EOF
fi
}


function mainRowsLabels() {
	style="${1}"

let width="${COL_WIDTH}"
let height="${ROW_HEIGHT}"
for (( ri=1; ri < ${ROWS}; ri++)); do
	let y="${BORDER} + ${ROW_0_HEIGHT} + ${ROW_SEP} + ((${ri} - 1) * (${ROW_SEP} + ${ROW_HEIGHT})) + (${ROW_HEIGHT} / 2) + (${LABEL_FONT_SIZE} / 4)"
	for (( ci=0; ci < ${COLS}; ci++)); do
		let x="${BORDER} + (${ci} * (${COL_WIDTH} + ${COL_SEP})) + (${COL_WIDTH} / 2)"
		if [ "${SPLIT_HANDS}" == "true" ] && [ ${ci} -ge ${COLS_HALF} ]; then
			let x="${x} - ${COL_SEP} + ${HANDS_SEP}"
		fi
		var="IDS$ri[$ci]"
		id="${!var}"
		if [ "${id}" == "${NULL_VALUE}" ]; then
			continue
		fi
		var="LABELS$ri[$ci]"
		label="${!var}"
		cat >> "${RES_SVG_FILE}" << EOF
    <text
       xml:space="preserve"
       style="${style}"
       x="${x}"
       y="${y}"
       id="key${id}Label"
       sodipodi:linespacing="125%"><tspan
         sodipodi:role="line"
         id="key${id}LabelTSpan"
         x="${x}"
         y="${y}">${label}</tspan></text>
EOF
	done
done
}



# Key frames

cat >> "${RES_SVG_FILE}" << EOF
  <g
     inkscape:groupmode="layer"
     inkscape:label="keyFrames"
     id="layerKeyFrames"
     style="display:inline">
EOF

style="fill:none;stroke:${STROKE_COLOR};stroke-width:${STROKE_WIDTH};stroke-opacity:1;display:inline"
numberBar "${style}" "Frame"
mainRows  "${style}" "Frame"



# Key fills

cat >> "${RES_SVG_FILE}" << EOF
  </g>
  <g
     inkscape:groupmode="layer"
     inkscape:label="keyFills"
     id="layerKeyFills"
     style="display:inline">
EOF
#     style="display:none">

style="fill:${FILL_COLOR};fill-opacity:${FILL_OPACITY};stroke:none;display:inline"
numberBar "${style}" "Fill"
mainRows  "${style}" "Fill"




# Key labels

cat >> "${RES_SVG_FILE}" << EOF
  </g>
  <g
     inkscape:groupmode="layer"
     inkscape:label="keyLabels"
     id="layerKeyLabels"
     style="display:inline">
EOF

style="font-size:${LABEL_FONT_SIZE}px;font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;letter-spacing:0px;word-spacing:0px;text-anchor:middle;fill:${LABEL_COLOR};fill-opacity:${LABEL_OPACITY};stroke:none;font-family:${LABEL_FONT_TYPE};-inkscape-font-specification:Courier 10 Pitch Bold"
numberBarLabel "${style}"
mainRowsLabels "${style}"


cat >> "${RES_SVG_FILE}" << EOF
  </g>
</svg>

EOF

