Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvSats.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


#include %rcvStatsRoutines.red

;***************** STATISTICAL FUNCTIONS ***********************
;****************** images and matrices  ***********************

rcvCountNonZero: function [arr [image! vector!]return: [integer!]
"Returns number of non zero values in image or matrix"
][
	t: type? arr
	if t = image! 	[n: _rcvCount arr]
	if t = vector!  [n: _rcvCountMat arr]
	n
]

rcvSum: function [arr [image! vector!] return: [block!] /argb
"Returns sum value of image or matrix as a block"
][
	t: type? arr
	if t = image! 	[	v: _rcvMeanInt arr
						a: v >>> 24
    					r: v and 00FF0000h >> 16 
    					g: v and FF00h >> 8 
    					b: v and FFh
    					sz: arr/size/x * arr/size/y
    					sa: a * sz
    					sr: r * sz
    					sg: g * sz
    					sb: b * sz
    					either argb [blk: reduce [sa sr sg sb]] [blk: reduce [sr sg sb]]
					]
	if t = vector!  [sum: _rcvSumMat arr blk: reduce [sum]]
	blk
]

rcvMean: function [arr [image! vector!] return: [tuple!] /argb
"Returns mean value of image or matrix as a tuple"
][
	t: type? arr
	if t = vector!  [m: _rcvMeanMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: _rcvMeanInt arr
					a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] [tp: make tuple! reduce [r g b]]
	]
	tp
]

rcvSTD: function [arr [image! vector!] return: [tuple!] /argb
"Returns standard deviation value of image or matrix as a tuple"
][
t: type? arr
	if t = vector!  [m: _rcvStdMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: _rcvStdInt arr
					a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] [tp: make tuple! reduce [r g b]]
	]
	tp
]	


rcvMedian: function [arr [image! vector!] return: [tuple!]
"Returns median value of image or matrix as a tuple"
][
t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 n: to integer! length? mat
					 pos: to integer! ((n + 1) / 2)
					 either odd? n  [pxl: make tuple! reduce [mat/(pos)]] 
					 				[m1: mat/(pos) m2: mat/(pos + 1) pxl: make tuple! reduce [(m1 + m2) / 2]]
	]
	if t = image! 	[img: make image! reduce [arr/size black] ;should be img: copy arr
					 img/rgb: copy sort arr/rgb
					 n: to integer! ((length? img/rgb) / 3) ; RGB channels only
					 pos: to integer! ((n + 1) / 2)
					 either odd? n [pxl: img/(pos)] [m1: img/(pos) m2: img/(pos + 1) pxl: (m1 + m2) / 2]
	]
	pxl
]	

rcvMinValue: function [arr [image! vector!] return: [tuple!]
"Minimal value in image or matrix as a tuple"
][
t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 pxl: make tuple! reduce [mat/1]
	]
	if t = image! 	[img: make image! reduce [arr/size black];should be img: copy arr
					 img/rgb: copy sort arr/rgb 
					 pxl: img/1
	]
	pxl
]	


rcvMaxValue: function [arr [image! vector!] return: [tuple!]
"Maximal value in image or matrix as a tuple"
][
	t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 pxl: make tuple! reduce [last mat]
	]
	if t = image! 	[img: make image! reduce [arr/size black];should be img: copy arr
					 img/rgb: copy sort arr/rgb 
					 pxl: last img
	]
	pxl
]	


rcvMinLoc: function [arr [image! vector!] arrSize [pair!]return: [pair!]
"Finds global minimum location in array"
][
	loc: 0x0
	ret: 0x0
	t: type? arr
	if t = vector! [ret: _rcvMinLocMat arr arrSize loc]
	if t = image! [ret: _rcvMinLoc arr loc]
	ret
]


rcvMaxLoc: function [arr [image! vector!] arrSize [pair!]return: [pair!]
"Finds global maximum location in array"
][
	loc: 0x0
	ret: 0x0
	t: type? arr
	if t = vector! [ret: _rcvMaxLocMat arr arrSize loc]
	if t = image! [ret: _rcvMaxLoc arr loc]
	ret
]

rcvHistogram: function [arr [image! vector!] return:  [vector!] /red /green /blue
"Calculates array histogram"
][
	histo: make vector! 256
	t: type? arr
	if t = vector! [_rcvHistoMat arr histo]
	if t = image! [
		case [
			red 	[_rcvHisto arr histo 1]
			green 	[_rcvHisto arr histo 2]
			blue 	[_rcvHisto arr histo 3]
		]	
	]
	histo
]


rcvSmoothHistogram: function [arr [vector!] return:  [vector!]
"This function smoothes the input histogram by a 3 points mean moving average."
] [
	histo: make vector! 256
	n: length? arr
	i: 2
	while [i < n] [
					histo/(i): (arr/(i - 1) + arr/(i) + arr/(i + 1)) / 3 
	 				i: i + 1
	]
	
	histo/1: histo/2
	histo/(n): histo/(n - 1)		
	histo
]



rcvHistogramEqualization: function [ image [vector!]   gLevels [integer!] 
"This function performs histogram equalization on the input image array"
] [
	n: length? image
	histo: make vector! 256 ;[0..255]
	sumH: make vector! 256
	constant: gLevels / to float! (n)	
	_rcvHistoMat image histo				; calculate histogram 
	_rcvSumHisto histo sumH					; calculate the sum of histogram
	_rcvEqualizeHisto image sumH constant	; transform input image to output image
]

; this function should be transformed to routine for faster access:)
rcvMakeTranscodageTable: function [n [percent!] return: [vector!]
"Creates a transcoding table for affine enhancement"
] [
	table: make vector! 256
	p1: to integer! 256 * n
	p2: to integer! 256 - p1
	diff: to float! p2 - p1
	i: 1
	while [i < p1] [table/(i): 0 i: i + 1]
	while [i < p2] [table/(i): to integer! ((i - p1) / diff) * 255   i: i + 1]
	while [i < 257][table/(i): 255 i: i + 1]
	table
]

rcvContrastAffine: function [image [vector!] n [percent!]
"Enhances image contrast with affine function" 
] [
	range: rcvMakeTranscodageTable n
	_rcvEqualizeContrast image range
]



rcvRangeImage: function [source [image!] return: [tuple!]
"Range value in Image as a tuple"
][
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	pxl1: img/1
	pxl2: img/(n)
	pxl2 - pxl1
]


rcvSortImage: function [source [image!] dst [image!]
"Ascending image sorting"
][
	dst/rgb: copy sort source/rgb 
]


{Quick Hull implementation
Based on Alexander Hristov's Java code
http://www.ahristov.com/tutorial/geometry-games/convex-hull.html}


{Vectors cross product: 3 points are a counter-clockwise turn if rcvCross > 0, 
clockwise if rcvCross < 0, and collinear if rcvCross = 0 because rcvCross is a determinant that
gives the signed area of the triangle formed by p1, p2 and p3}

rcvCross: function [A [pair!] B [pair!] P [pair!] return: [integer!]
][
	cp1: ((B/x - A/x) * (P/y - A/y)) - ((B/y - A/y) * (P/x - A/x))
	either (cp1 > 0) [1] [-1]
]

; Computes the square of the distance of point C to the segment defined by points AB
rcvPointDistance: function [A [pair!] B [pair!] C [pair!] return: [integer!]
][
	ABx: B/x - A/x
	ABy: B/Y - A/Y
	num: (ABx * (A/y - C/y)) - (ABy * (A/x - C/x))
	if num < 0 [num: negate num]
	num
]

rcvFindExtrema: function [points [block!] return: [block!]
"Finds minimal and maximal coordinates"
] [
	minPoint: 0x0
	maxPoint: 0x0
	minX: 32767
	maxX: 0
	n: length? points
	i: 1
	while [i <= n] [
		p: points/(i)
		if p/x < minX [minX: p/x minPoint: p]
		if p/x > maxX [maxX: p/x maxPoint: p]
		i: i + 1
	]
	make block! reduce [minPoint maxPoint]
]

rcvSeparateSets: function [ptsBlock [block!] return: [block!]
"Separates left and right set" 
][
	sBlock: copy ptsBlock
	nPoints: length? sBlock
	tmp: rcvFindExtrema ptsBlock
	leftSet: copy []
	rightSet: copy []
	i: 1
	while [i <= nPoints] [
		p: sBlock/(i)
		v: rcvCross tmp/1 tmp/2 p
		either (v = -1 ) [append leftSet p] [append rightSet p]
		i: i + 1
	]
	result: copy []
	append/only result leftSet
	append/only result rightSet
	result
] 

rcvHullSet: function [ A [pair!] B [pair!] aSet [block!] hull [block!]
] [
	insertPos: index? find hull B
	n: length? aSet
	if n = 0 [exit]
	if n = 1 [
		p: aSet/1
		insert at hull insertPos p
		exit
	]
	dist: furthestPoint: 0
	i: 1
	while [i <= n ] [
		p: aSet/(i)
		distance: rcvPointDistance A B p
		if (distance > dist) [
			dist: distance
			furthestPoint: i
		]
		i: i + 1
	]
	p: aSet/(furthestPoint)
	insert at hull insertPos p
	
	n: length? aSet
	
	;Determine who's to the left of AP
	leftSetAP: copy []
	i: 1 
	while [i <= n] [
		m: aSet/(i)
		if ((rcvCross A p m) = 1) [
			append leftSetAP m
		]
		i: i + 1
	]
	;Determine who's to the left of PB
	leftSetPB: copy []
	i: 1
	while [i <= n] [
		m: aSet/(i)
		if ( (rcvCross p B m) = 1) [
			append leftSetPB m
		]
		i: i + 1
	]
	rcvHullSet A P leftSetAP hull
    rcvHullSet P B leftSetPB hull	
]

rcvQuickHull: function [points [block!] return: [block!] /cw/ccw
"Finds the convex hull of a point set. Uses flag for orientation (cw/ccw) of convex hull"
][
	convexHull: copy []
	extrema: rcvFindExtrema points
	minP: first extrema
	maxP: second extrema
	append convexHull minP
	append convexHull maxP
	sets: rcvSeparateSets points
	left: first sets
	right: second sets
	; some pbs if set = 0 TBC
	if error? try [
			rcvHullSet minP maxP right convexHull
			rcvHullSet maxP minP left  convexHull] 
		[remove at convexHull 1] 
 	 either cw [reverse convexHull] [convexHull]
]

rcvContourArea: function [hull [block!] return: [float!]/signed
"Calculates the area of convex polygon"
] [
	b: copy hull
	n: length? b
	firstCoord: first b
	append b firstCoord
	sum1: 0
	sum2: 0
	i: 1
	while [i <= n] [
		sum1: sum1 + (b/(i)/x * b/(i + 1)/y)
		sum2: sum2 + (b/(i)/y * b/(i + 1)/x)
	i: i + 1
	]
	either signed [(sum1 - sum2) / 2.0] [absolute (sum1 - sum2) / 2.0]
]



