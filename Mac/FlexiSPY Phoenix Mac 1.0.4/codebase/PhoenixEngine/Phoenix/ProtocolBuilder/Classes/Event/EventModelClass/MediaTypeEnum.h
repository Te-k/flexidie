/*
 *  MediaTypeEnum.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 8/29/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

typedef enum {
	UNKNOWN_MEDIA = 0,
    
    /**** IMAGE ****/
	JPEG    = 1,
	GIF     = 2,
	BMP     = 3,
	EXIF    = 4,
	TIFF    = 5,
	RAW     = 6,
	PNG     = 7,
	PPM     = 8,
	PGM     = 9,
	PBM     = 10,
	PNM     = 11,
	ECW     = 12,
    ICO     = 13,
    CUR     = 14,
    
	/**** VIDEO ****/
	CGM     = 51,
	SVG     = 52,
	ODG     = 53,
	EPS     = 54,
	PDF     = 55,
	SWF     = 56,
	WMF     = 57,
	XPS     = 58,
	EMS     = 59,
	EMF_PLUS = 60,
	EMZ     = 61,
	
	MP4     = 101,
	WMV     = 102,
	ASF     = 103,
	THREE_GP = 104,
	THREE_G2 = 105,
	M4V     = 106,
	AVI     = 107,
	MOV     = 108,
    
    /**** AUDIO ****/
	MP3     = 201,
	AAC     = 202,
	AAC_PLUS    = 203,
	EAAC_PLUS   = 204,
	AMR_NB  = 205,
	AMR_WM  = 206,
	QCP     = 207,
	WMA     = 208,
	MIDI    = 210,
	RA      = 211,
	PCM     = 212,
	AIFF    = 213,
	BWF     = 214,
	AU      = 215,
	M4P     = 216,
	WAV     = 217,
    M4A     = 218,
    M4R     = 219
} MediaType;
