Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %motion.red
	Needs:	 'View
]

{ Based on
Collins, R., Lipton, A., Kanade, T., Fijiyoshi, H., Duggins, D., Tsin, Y., Tolliver, D., Enomoto,
N., Hasegawa, O., Burt, P., Wixson, L.: A system for video surveillance and monitoring. Tech.
rep., Carnegie Mellon University, Pittsburg, PA (2000)}


; all we need for computer vision with red
#include %../../libs/redcv.red ; for red functions

iSize: 320x240
prevImg: rcvCreateImage iSize
currImg: rcvCreateImage iSize
nextImg: rcvCreateImage iSize
d1: rcvCreateImage iSize
d2: rcvCreateImage iSize
r1: rcvCreateImage iSize
r2: rcvCreateImage iSize


margins: 10x10
threshold: 32
cam: none ; for camera object

to-text: function [val][form to integer! 0.5 + 128 * any [val 0]]


processCam: does [
	rcv2gray/average nextImg currImg	; transforms to grayscale since, we don't need color
	rcvAbsdiff  prevImg currImg d1		; difference between previous and current image
	rcvAbsdiff  currImg nextImg d2		; difference between current and next image
	rcvAnd d1 d2 r1						; AND differences
	rcv2BWFilter r1 r2 threshold 		; Applies B&W Filter to AND image
	prevImg: currImg					; previous image contains now the current image
	currImg: nextImg					; current image contains the next image				
	nextImg: to-image cam				; updates next image
	;nextImg: cam/image					; should work in red future version
]



view win: layout [
		title "Motion Detection"
		origin margins space margins
		text "Motion " 50 
		motion: field 70 rate 0:0:1 on-time [face/text: form rcvCountNonZero r2]
		text "Camera Size" 
		cSize: field 80
		
		btnQuit: button "Quit" 60x24 on-click [
			rcvReleaseImage prevImg
            rcvReleaseImage currImg
            rcvReleaseImage nextImg
            rcvReleaseImage d1
            rcvReleaseImage d2
            rcvReleaseImage r1
            rcvReleaseImage r2
			quit]
			
		return
		cam: camera iSize
		canvas: base iSize rate 0:0:1 on-time [processCam]
		return
		text 40 "Select" 
		cam-list: drop-list 180 on-create [face/data: cam/data]
		onoff: button "Start/Stop" 85 on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					motion/rate: none
					canvas/image: black
				][
					cam/selected: cam-list/selected
					prevImg: currImg: nextImg: to-image cam
					cSize/text: form currImg/size
					d1: rcvCreateImage currImg/size
					d2: rcvCreateImage currImg/size
					r1: rcvCreateImage currImg/size
					r2: rcvCreateImage currImg/size
					canvas/image: r2
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
					motion/rate: 0:0:0.04
					]
			]
		text "Filter" 40
		sl1: slider 180 [filter/text: to-text sl1/data threshold: to integer! filter/data ]
		filter: field 40 "32" 
		do [cam-list/selected: 1 motion/rate: canvas/rate: none sl1/data: 0.32 ]
]
	
	


