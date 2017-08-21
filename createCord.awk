#!/usr/bin/env awk
# Filters an SVG image of a stenography keyboard (see createBase.sh),
# so it represents a certain steno-cord (combination of keys).

# Converts an array of char's to a string.
func arrayToString(array, len, res) {
	res = ""
	for (i = 1; i <= len; i++) {
		res = res array[i]
	}
	return res
}

BEGIN {
	# Arguments
	# You may set these on the command line with -DVAR=VAL
	VERBOSE = 0
	FILE_BASE = "stenoboard"
	ALL_LAYERS_FILE = FILE_BASE "_full.svg"

	SIDES[1] = "l"
	SIDES[2] = "r"
	stenoAlphabet = "12#STKPWHRAO*-EUFRPBLGTSDZ"
	stenoAlphabetL = "12#STKPWHRAO*"
	stenoAlphabetR = "EUFRPBLGTSDZ"
	stenoAlphabetLen = split(stenoAlphabet, stenoAlphabetChars, "")
	stenoAlphabetLLen = split(stenoAlphabetL, stenoAlphabetCharsL, "")
	stenoAlphabetRLen = split(stenoAlphabetR, stenoAlphabetCharsR, "")

	FMT_CORD     = "  %-30s  -> %-15s - %-15s\n"
	FMT_CORD_NEG = "  %-30s !-> %-15s - %-15s\n"

	if (VERBOSE) {
		printf(FMT_CORD,
			stenoAlphabet,
			stenoAlphabetL,
			stenoAlphabetR)
	}
}

func charToLabels(char, labels, side) {

	if (char == "#") {
		num = 3
		labels[1] = "Sharp"
		labels[2] = "Sharp" SIDES[1]
		labels[3] = "Sharp" SIDES[2]
	} else if (char == "1" || char == "2") {
		num = 1
		labels[1] = "Fn" char
	} else if (char == "*") {
		num = 4
		labels[1] = "Star" SIDES[1] "1"
		labels[2] = "Star" SIDES[1] "2"
		labels[3] = "Star" SIDES[2] "1"
		labels[4] = "Star" SIDES[2] "2"
	} else {
		num = 4
		labels[1] = char
		labels[2] = char side
		labels[3] = char side "1"
		labels[4] = char side "2"
	}

	return num
}


func filterStenoSvg(cord, cordCharsLR) {

	deleteStr = ""
	for (si = 1; si <= 2; si++) {
		side = SIDES[si]
		for (ci = 1; ci <= cordCharsLR[si][0]; ci++) {
			char = cordCharsLR[si][ci]
			numLabels = charToLabels(char, labels, side)
			for (li = 1; li <= numLabels; li++) {
				deleteStr = deleteStr " --select=\"key" labels[li] "Fill\" --verb=EditDelete"
			}
		}
	}

	resFile = FILE_BASE "_cord_" cord ".svg"

	filterCmd = sprintf("cp %s %s && inkscape %s %s --verb=FileSave --verb=FileClose",
		ALL_LAYERS_FILE,
		resFile,
		resFile,
		deleteStr)

	print(filterCmd)
	#system(filterCmd) # TODO uncomment
}

func separateCordLR(cord, cordCharsLR) {
	# @param cord  this should be a subset of: "#STKPWHRAO*-EUFRPBLGTSDZ", for example: "STO-FRP"

	cordLen = split(cord, cordChars, "")
	cri = 0
	cli = 0
	right = 0
	ai = 1
	for (ci = 1; ci <= cordLen; ci++) {
		for (; cordChars[ci] != stenoAlphabetChars[ai]; ai++) {
			if (ai > 30) {
				printf("Invalid steno cord: %s\n", cord) >> "/dev/stderr"
				exit 2
			}
		}
		if (ai > 13) {
			right = 1
		}
		if (cordChars[ci] == "-") {
			continue
		}
		if (right == 1) {
			cordCharsLR[2][++cri] = cordChars[ci]
		} else {
			cordCharsLR[1][++cli] = cordChars[ci]
		}
	}
	cordCharsLR[1][0] = cli
	cordCharsLR[2][0] = cri
}

# Returns c = a - b, with a, b and c being arrays treated as sets.
# Example:
#   a = ( "1", "2", "3", "4")
#   b = ( "2", "3", "5" )
#   -> c = ( "1". "4" )
func diffSet(a, aLen, b, bLen, c) {
	ci = 0
	inBoth = 0
	for (ai = 1; ai <= aLen; ai++) {
		for (bi = 1; bi <= bLen; bi++) {
			if (a[ai] == b[bi]) {
				inBoth = 1
				continue
			}
		}
		if (inBoth == 0) {
			c[++ci] = a[ai]
		}
		inBoth = 0
	}
	return ci
}

func createStenoSvg(cord) {
	separateCordLR(cord, cordCharsLR)
	if (VERBOSE) {
		printf(FMT_CORD,
			cord,
			arrayToString(cordCharsLR[1], cli),
			arrayToString(cordCharsLR[2], cri))
	}

	# Init as 2D array
	nonCordLR[1][0] = -1
	nonCordLR[2][0] = -1
	nonCordLLen = diffSet(stenoAlphabetCharsL, stenoAlphabetLLen,
		cordCharsLR[1], cordCharsLR[1][0],
		nonCordLR[1]) 
	nonCordRLen = diffSet(stenoAlphabetCharsR, stenoAlphabetRLen,
		cordCharsLR[2], cordCharsLR[2][0],
		nonCordLR[2]) 
	nonCordLR[1][0] = nonCordLLen
	nonCordLR[2][0] = nonCordRLen
	if (VERBOSE) {
		printf(FMT_CORD_NEG,
			cord,
			arrayToString(nonCordL, nonCordLLen),
			arrayToString(nonCordR, nonCordRLen))
	}

	filterStenoSvg(cord, nonCordLR)
}

# Interpret each line in the input file as a steno cord,
# and create the corresponding SVG.
{
	cord = $0
	createStenoSvg(cord)
}

