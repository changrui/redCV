Red [	Title:   "Roberts Filter "	Author:  "Francois Jouen"	File: 	 %roberts.red	Needs:	 'View]; last Red Master required!#include %../../libs/redcv.red ; for redCV functionsmargins: 10x10defSize: 512x512img1: rcvCreateImage defSizedst:  rcvCreateImage defSizegray: rcvCreateImage defSizecurrentImage:  rcvCreateImage defSizeisFile: falseparam: 3loadImage: does [    isFile: false	canvas/image/rgb: black	canvas/size: 0x0	tmp: request-file	if not none? tmp [		fileName: to string! to-local-file tmp		win/text: copy "Edges detection: Roberts "		append win/text fileName		img1: rcvLoadImage tmp		gray: rcvLoadImage/grayscale tmp		currentImage rcvCreateImage img1/size		either cb/data [currentImage: rcvCloneImage gray]					   [currentImage: rcvCloneImage img1]		dst:  rcvCloneImage currentImage		; update faces		if img1/size/x >= defSize/x [			win/size/x: img1/size/x + 20			win/size/y: img1/size/y + 256		] 		either (img1/size/x = img1/size/y) [bb/size: 120x120] [bb/size: 160x120]		canvas/size: img1/size		canvas/offset/x: (win/size/x - img1/size/x) / 2		bb/image: img1		canvas/image: dst		isFile: true		rcvRoberts currentImage dst currentImage/size param		r1/data: false		r2/data: false		r3/data: true		r4/data: false	]]; ***************** Test Program ****************************view win: layout [		title "Edges detection: Roberts"		origin margins space margins		button 60 "Load" 		[loadImage]			cb: check "Grayscale"	[								either cb/data [currentImage: rcvCloneImage gray]					   			[currentImage: rcvCloneImage img1]					   			rcvRoberts currentImage dst currentImage/size param								]							button 60 "Quit" 		[rcvReleaseImage img1 								rcvReleaseImage gray								rcvReleaseImage currentImage								rcvReleaseImage dst Quit]		return		bb: base 160x120 img1		return		text middle 100x20 "Roberts Direction"		r1: radio "Horizontal" 	[param: 1 rcvRoberts currentImage dst currentImage/size param]		r2: radio "Vertical" 	[param: 2 rcvRoberts currentImage dst currentImage/size param]			r3:	radio "Both" 		[param: 3 rcvRoberts currentImage dst currentImage/size param]		r4:	radio "Magnitude" 	[param: 4 rcvRoberts currentImage dst currentImage/size param]		return		canvas: base 512x512 dst			do [r3/data: true]]